import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/models/jsonable.dart';

enum StudentStatus { SEARCHING, WORKING, FINISHED, IRRELEVANT }

StudentStatus DEFAULT_STATUS = StudentStatus.SEARCHING;

/// student interface
abstract class Student implements Jsonable {
  FileContainer get files;

  String personalID;
  String firstName, lastName;
  String phoneNumber;
  String email;

  int studyYear;

  StudentStatus status;

  DateTime get lastUpdate;
  DateTime get loadDate;

  Map<String, dynamic> toJson();
}

