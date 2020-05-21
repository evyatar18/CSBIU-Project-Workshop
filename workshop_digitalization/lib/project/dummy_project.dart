import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/person/firebase_person.dart';
import 'package:workshop_digitalization/person/person.dart';
import 'package:workshop_digitalization/project/project.dart';

class DummyProject implements Project {
  @override
  Memo comments;

  @override
  Person contact = FirebasePerson();

  @override
  DateTime endDate;

  @override
  String initiatorFirstName = 'dan';

  @override
  String initiatorLastName;

  @override
  Person mentor = FirebasePerson(firstName: 'a',lastName: 'd');

  @override
  String mentorTechAbility;

  @override
  int numberOfStudents =5 ;

  @override
  List<String> projectChallenges;

  @override
  String projectDomain;

  @override
  String projectGoal;

  @override
  List<String> projectInnovativeDetails;

  @override
  ProjectStatus projectStatus;

  @override
  String projectSubject;

  @override
  Memo skills;

  @override
  // TODO: implement lastUpdate
  DateTime get lastUpdate => null;

  @override
  // TODO: implement loadDate
  DateTime get loadDate => null;

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return null;
  }
  
}
