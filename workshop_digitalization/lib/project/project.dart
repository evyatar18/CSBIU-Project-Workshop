import 'package:workshop_digitalization/global/identified_type.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/person/person.dart';
import 'package:workshop_digitalization/student/student.dart';

enum ProjectStatus { NEW, CONTINUE }

abstract class Project implements StringIdentified {
  String initiatorFirstName;
  String initiatorLastName;

  Person contact;

  String projectSubject;
  String projectDomain;
  String projectGoal;

  DateTime endDate;

  int numberOfStudents;

  String skills;

  Person mentor;

  List<String> projectChallenges;
  List<String> projectInnovativeDetails;

  ProjectStatus projectStatus;

  String mentorTechAbility;

  String comments;

  DateTime get lastUpdate;
  DateTime get loadDate;

  List<String> studentIds;
  List<Student> get students;
}
