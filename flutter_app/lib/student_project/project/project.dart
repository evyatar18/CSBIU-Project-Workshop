import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/global/disposable.dart';
import 'package:workshop_digitalization/global/identified_type.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/person/person.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

abstract class Project implements StringIdentified {
  Person initiator;

  Person contact;

  String projectSubject;
  String projectDomain;
  String projectGoal;

  DateTime endDate;

  int get numberOfStudents;

  String skills;

  Person mentor;

  List<String> projectChallenges;
  List<String> projectInnovativeDetails;

  String projectStatus;

  String mentorTechAbility;

  String comments;

  DateTime get lastUpdate;
  DateTime get loadDate;

  List<String> studentIds;
  List<Student> get students;

  FileContainer get files;
  MemoManager get memos;
}

abstract class ProjectManager<ProjectType extends Project> implements Disposable {

  Stream<List<ProjectType>> get projects;
  List<ProjectType> get latestProjects;

  /// get a project with a given id
  ProjectType getProject(String id);

  /// create a new project
  Future<ProjectType> createEmpty();

  /// save an edited project
  Future<void> save(ProjectType project);

  /// delete a given project
  Future<void> delete(ProjectType project);
}