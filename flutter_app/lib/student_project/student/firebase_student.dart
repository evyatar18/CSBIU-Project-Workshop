import 'dart:async';

import 'package:flamingo/flamingo.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/files/firebase.dart';
import 'package:workshop_digitalization/dynamic_firebase/roots/active_root.dart';
import 'package:workshop_digitalization/global/smart_doc_accessor.dart';
import 'package:workshop_digitalization/memos/firebase_memo.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/progress/progress.dart';
import 'package:workshop_digitalization/student_project/grade/firebase_grade.dart';
import 'package:workshop_digitalization/student_project/grade/grade.dart';

import '../project/project.dart';
import 'student.dart';

class FirebaseStudent extends Document<FirebaseStudent> implements Student {
  FBFileContainer _files;
  MemoManager<Memo> _memos;

  final ActiveRoot root;

  FirebaseStudent(
    this.root, {
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }) : super(
          id: id,
          snapshot: snapshot,
          values: values,
          collectionRef: collectionRef,
        );

  @override
  FileContainer get files {
    if (_files == null)
      _files = FBFileContainer(
        root.firebase.storage,
        super.reference.collection("files"),
      );
    return _files;
  }

  @override
  MemoManager<Memo> get memos {
    if (_memos == null)
      _memos = FirebaseMemoManager(
        root.firebase,
        super.reference.collection("memos"),
      );
    return _memos;
  }

  @override
  String email = "";

  @override
  String firstName = "";

  @override
  String lastName = "";

  @override
  String personalID = "";

  @override
  String phoneNumber = "";

  StudentStatus _status;
  @override
  StudentStatus get status => _status ?? DEFAULT_STUDENT_STATUS;

  String firebaseProjectId;

  set status(StudentStatus stat) => _status = stat;

  @override
  int studyYear = DateTime.now().year;

  @override
  DateTime get lastUpdate =>
      super.updatedAt != null ? super.updatedAt.toDate() : DateTime.now();

  @override
  DateTime get loadDate =>
      super.createdAt != null ? super.createdAt.toDate() : DateTime.now();

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();

    writeNotNull(data, "id", personalID);
    writeNotNull(data, "firstName", firstName);
    writeNotNull(data, "lastName", lastName);
    writeNotNull(data, "phone", phoneNumber);
    writeNotNull(data, "email", email);
    writeNotNull(data, "year", studyYear);
    if (status != null) writeNotNull(data, "status", status.index);
    write(data, "projectId", firebaseProjectId);

    writeModelNotNull(data, "grade", _grade);

    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    personalID = valueFromKey<String>(data, "id");
    firstName = valueFromKey<String>(data, "firstName");
    lastName = valueFromKey<String>(data, "lastName");
    phoneNumber = valueFromKey<String>(data, "phone");
    email = valueFromKey<String>(data, "email");
    studyYear = valueFromKey<int>(data, "year");
    status = StudentStatus.values[valueFromKey<int>(data, "status")];

    firebaseProjectId = valueFromKey<String>(data, "projectId");

    _grade = FirebaseGrade(values: valueMapFromKey(data, "grade"));
  }

  @override
  Project get project =>
      root.projectManager.getProject(firebaseProjectId);

  Future<void> dispose() {
    return Future.wait([
      if (_files != null) _files.dispose(),
      if (_memos != null) _memos.dispose(),
    ]);
  }

  FirebaseGrade _grade;
  @override
  Grade get grade => _grade ?? (_grade = FirebaseGrade());
  set grade(Grade g) => _grade = g;
}

/// a `StudentManager` which has a firebase backend
class FirebaseStudentManager implements StudentManager<FirebaseStudent> {
  /// a reference to the student collection
  final CollectionReference _collection;

  /// a SmartDocumentAccessor to manage this collection
  final _docAccessor = SmartDocumentAccessor();

  /// the current firebase root which is used for this document
  final ActiveRoot _root;

  StreamSubscription _subscription;
  BehaviorSubject<List<FirebaseStudent>> _students =
      BehaviorSubject<List<FirebaseStudent>>();

  FirebaseStudentManager(this._root)
      : _collection = _root.root.reference.collection("students") {
    _subscription = _collection.snapshots().listen(_handleSnapshots);
  }

  /// disposes of old students (after a firebase update occurs, we create a completely new instance for each student)
  Future<void> _disposeElements() {
    final elements = _students.value;
    if (elements == null) {
      return Future.sync(() => null);
    } else {
      return Future.wait(elements.map((e) => e.dispose()));
    }
  }

  /// handles firebase snapshots
  void _handleSnapshots(QuerySnapshot snapshot) {
    // disposes of all currently stored students
    _disposeElements();

    // add all existing (not deleted) students
    _students.add(
      snapshot.documents
          .where((doc) => !_docAccessor.isDeleted(doc.data))
          .map((e) =>
              FirebaseStudent(_root, collectionRef: _collection, snapshot: e))
          .toList(),
    );
  }

  Stream<List<FirebaseStudent>> get students => _students.stream;
  List<FirebaseStudent> get latestStudents => _students.value;

  Future<FirebaseStudent> createEmpty() async {
    final student = FirebaseStudent(_root, collectionRef: _collection);
    await _docAccessor.save(student);
    return student;
  }

  Future<void> delete(FirebaseStudent student) async {
    // delete the project of the student if it exists
    final project = student.project;
    if (project != null) {
      final projs = _root.projectManager;
      project.studentIds = project.studentIds..remove(student.id);
      await projs.save(project);
    }

    student.dispose();
    await _docAccessor.delete(student);
  }

  Future<void> save(FirebaseStudent student) async {
    _docAccessor.update(student);
  }

  FirebaseStudent getStudent(String id) {
    return latestStudents?.firstWhere(
      (element) => element.id == id,
      orElse: () => null,
    );
  }

  /// create a `FirebaseStudent` instance from a given `Student` instance
  FirebaseStudent _fromStudent(Student s) {
    return FirebaseStudent(_root, collectionRef: _collection)
      ..personalID = s.personalID
      ..firstName = s.firstName
      ..lastName = s.lastName
      ..phoneNumber = s.phoneNumber
      ..studyYear = s.studyYear
      ..status = s.status
      ..email = s.email;
  }

  Stream<ProgressSnapshot> addStudents(List<Student> batch) async* {
    final taskName = "Writing ${batch.length} Students";
    yield ProgressSnapshot(taskName, "Preparing students...", 0);

    // TODO: the students have to be divided into batches of 500 at max
    // firebase does not support adding more than 500 in a batch
    // since this shouldn't happen we didn't bother implementing this division
    // but if it poses an issue it might need to be implemented
    final firebaseStudents = batch.map(_fromStudent);
    final writeBatch = Batch();
    firebaseStudents.forEach(writeBatch.save);

    yield ProgressSnapshot(taskName, "Uploading students.", 0.5);

    try {
      await writeBatch.commit();
      yield ProgressSnapshot(taskName, "Uploaded ${batch.length} students.", 1);
    } catch (e) {
      yield ProgressSnapshot(taskName, "Error occurred: $e", 0.5, failed: true);
    }
  }

  Future<void> dispose() async {
    try {
      await _disposeElements();
      await _subscription?.cancel();
      await _students.close();
    } catch (e, stack) {
      print("exception: $e");
      print("stack: $stack");
      rethrow;
    }
  }
}
