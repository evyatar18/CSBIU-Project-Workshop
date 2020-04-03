import 'name.dart';

enum StudentStatus {
  SEARCHING,
  WORKING,
  FINISHED,
  IRRELEVANT
}

abstract class Student {
  String id;
  Name fullName;
  String phoneNumber;
  String email;

  int studyYear;

  StudentStatus status;

  DateTime lastUpdate;
  DateTime loadDate;
}