import 'dart:math';

import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/student_project/grade/grade.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

class DummyStudent implements Student {
  @override
  String email = randomString(10);

  @override
  String firstName = randomString(10);

  @override
  String lastName = randomString(10);

  @override
  String personalID = randomString(10);

  @override
  String phoneNumber = randomString(10);
  static Random _random = new Random();
  @override
  StudentStatus status =
      StudentStatus.values[_random.nextInt(StudentStatus.values.length)];

  @override
  int studyYear = _random.nextInt(2021);

  @override
  // TODO: implement files
  FileContainer get files => null;

  @override
  // TODO: implement id
  String get id => null;

  @override
  // TODO: implement lastUpdate
  DateTime get lastUpdate => null;

  @override
  // TODO: implement loadDate
  DateTime get loadDate => null;

  @override
  // TODO: implement memos
  MemoManager<Memo> get memos => null;

  @override
  // TODO: implement project
  Future<Project> get project => null;

  @override
  void setProject(String projectId) {
    // TODO: implement setProject
  }

  @override
  Grade grade;
}
