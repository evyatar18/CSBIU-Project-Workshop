import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/student_project/grade/grade.dart';

import '../project/project.dart';
import 'student.dart';

class LocalStudent implements Student {
  @override
  String email;

  @override
  String firstName;

  @override
  String lastName;

  @override
  String personalID;

  @override
  String phoneNumber;

  @override
  StudentStatus status;

  @override
  int studyYear;
  LocalStudent({
    this.email,
    this.firstName,
    this.lastName,
    this.personalID,
    this.phoneNumber,
    this.status,
    this.studyYear,
  });

  static final List<String> fields = List.unmodifiable(
    ['id', 'firstName', 'lastName', 'phoneNumber', 'email', 'year'],
  );

  static List<String> getFields() => fields;

  static String nullIfEmpty(String s) {
    return s == null || s.isEmpty ? null : s;
  }

  factory LocalStudent.fromJson(Map<String, dynamic> json) {
    return new LocalStudent(
      email: nullIfEmpty(json["email"]),
      firstName: nullIfEmpty(json['firstName']),
      lastName: nullIfEmpty(json['lastName']),
      personalID: nullIfEmpty(json['id'].toString()),
      phoneNumber: nullIfEmpty(json['phoneNumber'].toString()),
      // status: StudentStatus.values[json['status']],
      status: DEFAULT_STUDENT_STATUS,
      studyYear: int.parse(nullIfEmpty(json['year']?.toString())) ??
          DateTime.now().year,
    );
  }

  @override
  FileContainer get files => null;

  @override
  String get id => null;

  @override
  DateTime get lastUpdate => null;

  @override
  DateTime get loadDate => null;

  @override
  MemoManager<Memo> get memos => null;

  @override
  Project get project => null;

  @override
  Grade grade;
}
