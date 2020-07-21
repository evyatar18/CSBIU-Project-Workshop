import 'dart:async';

import 'package:flamingo/flamingo.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/files/firebase.dart';
import 'package:workshop_digitalization/firebase_consts/active_root.dart';
import 'package:workshop_digitalization/global/smart_doc_accessor.dart';
import 'package:workshop_digitalization/memos/firebase_memo.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/person/person.dart';
import 'package:workshop_digitalization/person/firebase_person.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/firebase_student.dart';

class FirebaseProject extends Document<FirebaseProject> implements Project {
  @override
  String comments;

  FirebasePerson _contact;
  @override
  Person get contact => _contact ?? FirebasePerson();

  @override
  set contact(Person p) {
    _contact = FirebasePerson.fromPerson(p);
  }

  @override
  DateTime endDate;

  FirebasePerson _initiator;
  @override
  Person get initiator => _initiator ?? FirebasePerson();

  set initiator(Person p) {
    _initiator = FirebasePerson.fromPerson(p);
  }

  @override
  Person get mentor => _mentor ?? FirebasePerson();

  @override
  set mentor(Person p) {
    _mentor = FirebasePerson.fromPerson(p);
  }

  FirebasePerson _mentor;

  @override
  List<String> projectChallenges;

  @override
  String projectDomain;

  @override
  String projectGoal;

  @override
  List<String> projectInnovativeDetails;

  String _projectStatus;

  @override
  String get projectStatus => _projectStatus ?? "No Status";
  set projectStatus(stat) {
    _projectStatus = stat;
  }

  @override
  String projectSubject;

  @override
  String skills;

  @override
  int get numberOfStudents => _studentIds?.length ?? 0;

  @override
  String mentorTechAbility;

  final ActiveRoot root;

  FirebaseProject(
    this.root, {
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }) : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef: collectionRef);

  DateTime get lastUpdate =>
      super.updatedAt != null ? super.updatedAt.toDate() : DateTime.now();

  DateTime get loadDate =>
      super.createdAt != null ? super.createdAt.toDate() : DateTime.now();

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();

    writeModelNotNull(data, 'initiator', _initiator);
    writeModelNotNull(data, 'contact', _contact);
    writeNotNull(data, 'projectSubject', projectSubject);
    writeNotNull(data, 'projectDomain', projectDomain);
    writeNotNull(data, 'projectGoal', projectGoal);
    writeNotNull(data, 'endDate', endDate);

    writeModelNotNull(data, 'mentor', _mentor);
    writeNotNull(data, 'projectChallenges', projectChallenges);
    writeNotNull(data, 'projectInnovativeDetails', projectInnovativeDetails);
    writeNotNull(
      data,
      'projectStatus',
      projectStatus,
    );
    writeNotNull(data, 'mentorTechAbility', mentorTechAbility);

    writeNotNull(data, 'studentIds', _studentIds);

    // PROBLEMATIC
    writeNotNull(data, 'comments', comments);
    // PROBLEMATIC
    writeNotNull(data, 'skills', skills);

    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    comments = valueFromKey<String>(data, 'comments');
    contact = FirebasePerson(
        values: valueMapFromKey<String, dynamic>(data, 'contact'));
    endDate = valueFromKey<Timestamp>(data, 'endDate')?.toDate();
    initiator = FirebasePerson(
        values: valueMapFromKey<String, dynamic>(data, 'initiator'));
    mentor = FirebasePerson(
        values: valueMapFromKey<String, dynamic>(data, 'mentor'));
    projectChallenges = valueListFromKey<String>(data, 'projectChallenges');
    projectDomain = valueFromKey<String>(data, 'projectDomain');
    projectGoal = valueFromKey<String>(data, 'projectGoal');
    projectInnovativeDetails =
        valueListFromKey<String>(data, 'projectInnovativeDetails');
    projectStatus = valueFromKey<String>(data, 'projectStatus') ?? "No Status";
    projectSubject = valueFromKey<String>(data, 'projectSubject');
    skills = valueFromKey<String>(data, 'skills');
    mentorTechAbility = valueFromKey<String>(data, 'mentorTechAbility');
    _studentIds = valueListFromKey(data, 'studentIds') ?? <String>[];
  }

  var _studentIds = <String>[];
  @override
  List<String> get studentIds => List.from(_studentIds);

  set studentIds(List<String> ids) {
    final toRemove = _studentIds.where((element) => !ids.contains(element));
    final toAdd = ids.where((element) => !_studentIds.contains(element));

    final projs = root.projectManager;

    toRemove
        .forEach((studentId) => projs.queueRemoveStudent(this.id, studentId));
    toAdd.forEach((studentId) => projs.queueAddStudent(this.id, studentId));

    projs.save(this);
  }

  @override
  List<FirebaseStudent> get students {
    final studsInstance = root.studentManager;
    final studs =
        _studentIds.map((id) => studsInstance.getStudent(id)).toList();

    return studs.where((element) => element != null).toList();
  }

  Future<void> dispose() {
    var tasks = <Future>[
      if (_files != null) _files.dispose(),
      if (_memos != null) _memos.dispose()
    ];

    return Future.wait(tasks);
  }

  FileContainer _files;
  FileContainer get files {
    if (_files == null) {
      _files = FBFileContainer(
        root.firebase.storage,
        super.reference.collection("files"),
      );
    }

    return _files;
  }

  MemoManager _memos;
  MemoManager get memos {
    if (_memos == null) {
      _memos = FirebaseMemoManager(
        root.firebase,
        super.reference.collection("memos"),
      );
    }

    return _memos;
  }
}

class FirebaseProjectManager extends ProjectManager<FirebaseProject> {
  final CollectionReference _collection;
  final _projects = BehaviorSubject<List<FirebaseProject>>();
  final ActiveRoot root;

  StreamSubscription _subscription;

  FirebaseProjectManager(this.root)
      : _collection = root.root.reference.collection("projects") {
    _subscription = _collection
        .snapshots()
        .listen(_projectSnapshotListener, cancelOnError: false);
  }

  final _docAccessor = SmartDocumentAccessor();

  final _addQueue = <String, List<String>>{};
  final _deleteQueue = <String, List<String>>{};

  Stream<List<FirebaseProject>> get projects => _projects.stream;
  List<FirebaseProject> get latestProjects => _projects.stream.value;

  FirebaseProject getProject(String id) => latestProjects?.firstWhere(
        (element) => element.id == id,
        orElse: () => null,
      );

  Future<FirebaseProject> createEmpty() async {
    FirebaseProject fbProject =
        FirebaseProject(this.root, collectionRef: _collection);
    return Future.value(fbProject);
  }

  Future<void> save(FirebaseProject project) async {
    final projectId = project.id;

    final addQueue = List.of(_getQueue(_addQueue, projectId));
    final deleteQueue = List.of(_getQueue(_deleteQueue, projectId));

    _clearQueue(_addQueue, projectId);
    _clearQueue(_deleteQueue, projectId);

    // remove not needed elements
    addQueue.removeWhere((element) => deleteQueue.contains(element));
    deleteQueue.removeWhere((element) => !project.studentIds.contains(element));
    addQueue.removeWhere((element) => project.studentIds.contains(element));

    final projectDocumentId = project.id;
    await _setProjectIds(
      List.of(addQueue)..addAll(deleteQueue),
      (element) => addQueue.contains(element) ? projectDocumentId : null,
    );

    /* delete students of this project from their old projects */
    final removeFromProjects = addQueue
        .map((studId) {
          // find the old project of this student
          return latestProjects
              .where((proj) => proj.studentIds.contains(studId))
              .map((proj) {
            proj._studentIds.remove(studId);
            return proj;
          }).toList();
        })
        .expand((list) => list)
        .toSet()
        .map((proj) => _docAccessor.save(proj));

    try {
      await Future.wait(removeFromProjects);
    } catch (e) {
      print("error on firebase project (deleting from previous projects): $e");
    }
    /* finish deleting from old projects */

    project._studentIds.addAll(addQueue);
    project._studentIds.removeWhere((id) => deleteQueue.contains(id));
    return _docAccessor.save(project);
  }

  Future<void> delete(FirebaseProject project) async {
    await project.dispose();

    await Future.wait([
      _docAccessor.delete(project),
      _setProjectIds(project.studentIds, (stud) => null)
    ]);

    final projectId = project.id;

    // clear add and delete queues
    _clearQueue(_addQueue, projectId);
    _clearQueue(_deleteQueue, projectId);
  }

  Future<void> _disposeElements() {
    final projects = _projects.value;
    if (projects == null) {
      return Future.value();
    }
    return Future.wait(projects.map((p) => p.dispose()));
  }

  @override
  Future<void> dispose() async {
    await _disposeElements();
    await _subscription.cancel();
    await _projects.close();
  }

  void _projectSnapshotListener(QuerySnapshot snapshot) {
    _disposeElements();

    final projects = snapshot.documents
        .where((doc) => !_docAccessor.isDeleted(doc.data))
        .map(
          (doc) => FirebaseProject(
            this.root,
            collectionRef: _collection,
            snapshot: doc,
          ),
        )
        .toList();

    _projects.add(projects);
  }

  Future<void> _setProjectIds(List<String> studentIds,
      String Function(String) studentIdToProjectId) async {
    final studs = root.studentManager;

    final tasks = studentIds.map((studentId) async {
      final student = studs.getStudent(studentId);
      if (student == null) {
        return;
      }

      student.firebaseProjectId = studentIdToProjectId(studentId);

      try {
        await studs.save(student);
      } catch (e) {
        print("firebase_project.dart::313 - error: $e");
      }
    });

    await Future.wait(tasks);
  }

  List<String> _getQueue(Map<String, List<String>> queue, String projectId) {
    var lst = queue[projectId];
    if (lst == null) {
      queue[projectId] = (lst = <String>[]);
    }
    return lst;
  }

  void _clearQueue(Map<String, List<String>> queue, String projectId) {
    queue[projectId] = null;
  }

  void _addToQueue(
      Map<String, List<String>> queue, String projectId, String studentId) {
    final lst = _getQueue(queue, projectId);
    if (!lst.contains(studentId)) {
      lst.add(studentId);
    }
  }

  void queueAddStudent(String projectId, String studentId) =>
      _addToQueue(_addQueue, projectId, studentId);

  void queueRemoveStudent(String projectId, String studentId) =>
      _addToQueue(_deleteQueue, projectId, studentId);
}
