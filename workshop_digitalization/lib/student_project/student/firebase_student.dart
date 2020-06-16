import 'dart:async';

import 'package:flamingo/flamingo.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/files/firebase.dart';
import 'package:workshop_digitalization/global/smart_doc_accessor.dart';
import 'package:workshop_digitalization/memos/firebase_memo.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/progress/progress.dart';

import '../firebase_managers.dart';
import '../project/project.dart';
import 'student.dart';

class FirebaseStudent extends Document<FirebaseStudent> implements Student {
  FBFileContainer _files;
  MemoManager<Memo> _memos;

  FirebaseStudent({
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
      _files = FBFileContainer(super.reference.collection("files"));
    return _files;
  }

  @override
  MemoManager<Memo> get memos {
    if (_memos == null)
      _memos = FirebaseMemoManager(super.reference.collection("memos"));
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
  StudentStatus get status => _status ?? DEFAULT_STATUS;

  String firebaseProjectId;

  set status(StudentStatus stat) => _status = stat;

  @override
  int studyYear = DateTime.now().year;

  // TODO: convert timezones if needed
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
    writeNotNull(data, "projectId", firebaseProjectId);

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
  }

  @override
  Future<Project> get project async =>
      (await FirebaseManagers.instance.projects).getProject(firebaseProjectId);

  Future<void> dispose() async {}
}

class FirebaseStudentManager implements StudentManager<FirebaseStudent> {
  final _collection = Flamingo.instance.rootReference.collection("students");
  final _docAccessor = SmartDocumentAccessor();

  StreamSubscription _subscription;
  BehaviorSubject<List<FirebaseStudent>> _students =
      BehaviorSubject<List<FirebaseStudent>>();

  FirebaseStudentManager() {
    _subscription = _collection.snapshots().listen(_handleSnapshots);
  }

  Future<void> _disposeElements() async {
    if (!_students.hasValue) {
      return;
    }

    final elements = _students.value;
    await Future.wait(elements.map((e) => e.dispose()));
  }

  void _handleSnapshots(QuerySnapshot snapshot) {
    _disposeElements();

    _students.add(
      snapshot.documents
          .where((doc) => !_docAccessor.isDeleted(doc.data))
          .map((e) => FirebaseStudent(collectionRef: _collection, snapshot: e))
          .toList(),
    );
  }

  Stream<List<FirebaseStudent>> get students => _students.stream;
  List<FirebaseStudent> get latestStudents => _students.value;

  Future<FirebaseStudent> createEmpty() async {
    final student = FirebaseStudent(collectionRef: _collection);
    await _docAccessor.save(student);
    return student;
  }

  Future<void> delete(FirebaseStudent student) async {
    final project = await student.project;

    if (project != null) {
      final projs = await FirebaseManagers.instance.projects;
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
    return latestStudents.firstWhere(
      (element) => element.id == id,
      orElse: () => null,
    );
  }

  FirebaseStudent _fromStudent(Student s) {
    return FirebaseStudent(collectionRef: _collection)
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
    await _disposeElements();
    await _subscription?.cancel();
    await _students.close();
  }
}
