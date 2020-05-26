import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/global/disposable.dart';
import 'package:workshop_digitalization/global/identified_type.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/progress/progress.dart';
import 'package:workshop_digitalization/project/project.dart';

enum StudentStatus { SEARCHING, WORKING, FINISHED, IRRELEVANT }

StudentStatus DEFAULT_STATUS = StudentStatus.SEARCHING;

/// student interface
abstract class Student implements StringIdentified {
  FileContainer get files;

  String personalID;
  String firstName, lastName;
  String phoneNumber;
  String email;

  int studyYear;

  StudentStatus status;

  DateTime get lastUpdate;
  DateTime get loadDate;

  MemoManager get memos;

  Project get project;
  void setProject(String projectId);
}

abstract class StudentManager<StudentType extends Student> implements Disposable {
  Stream<List<StudentType>> get students;
  List<StudentType> get latestStudents;

  Future<StudentType> createEmpty();
  Future<void> delete(StudentType student);
  Future<void> save(StudentType student);

  StudentType getStudent(String id);

  Stream<ProgressSnapshot> addStudents(List<Student> batch);
}