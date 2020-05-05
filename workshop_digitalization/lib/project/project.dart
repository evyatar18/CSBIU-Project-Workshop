import 'package:workshop_digitalization/global/json/jsonable.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/person/person.dart';

enum ProjectStatus { NEW, CONTINUE }

abstract class Project implements Jsonable {
  String initiatorFirstName;
  String initiatorLastName;

  Person contact;

  String projectSubject;
  String projectDomain;
  String projectGoal;

  DateTime endDate;

  int numberOfStudents;

  Memo skills;

  Person mentor;

  List<String> projectChallenges;
  List<String> projectInnovativeDetails;

  ProjectStatus projectStatus;

  String mentorTechAbility;

  Memo comments;

  DateTime get lastUpdate;
  DateTime get loadDate;
}
