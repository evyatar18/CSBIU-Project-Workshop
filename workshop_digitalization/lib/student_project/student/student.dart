import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/global/disposable.dart';
import 'package:workshop_digitalization/global/identified_type.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/progress/progress.dart';
import 'package:workshop_digitalization/student_project/grade/grade.dart';

import '../project/project.dart';

enum StudentStatus { SEARCHING, WORKING, FINISHED, IRRELEVANT }
const StudentStatus DEFAULT_STUDENT_STATUS = StudentStatus.SEARCHING;

String studentStatusText(StudentStatus status) {
  switch(status) {
    case StudentStatus.SEARCHING:
      return "searching";
    case StudentStatus.WORKING:
      return "working";
    case StudentStatus.FINISHED:
      return "finished";
    case StudentStatus.IRRELEVANT:
      return "irrelevant";
  }

  return null;
}

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

  Grade grade;

  Project get project;
}

abstract class StudentManager<StudentType extends Student> implements Disposable {
  Stream<List<StudentType>> get students;
  List<StudentType> get latestStudents;

  /// creates a new student
  Future<StudentType> createEmpty();

  /// deletes a given student
  Future<void> delete(StudentType student);

  /// saves the given student
  Future<void> save(StudentType student);

  /// get a student by its id
  StudentType getStudent(String id);

  /// add a batch of students
  Stream<ProgressSnapshot> addStudents(List<Student> batch);
}