import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';
import 'package:workshop_digitalization/person/person.dart';

Map<String, dynamic> studentToData(Student student) {
  final data = Map<String, dynamic>();

  data['id'] = student.personalID;
  data["firstName"] = student.firstName;
  data["lastName"] = student.lastName;
  data["phone"] = student.phoneNumber;
  data["email"] = student.email;
  data["year"] = student.studyYear;
  if (student.status != null) data["status"] = student.status.toString();
  data["garde"] = student.grade.grade;
  data["comments"] = student.grade.comments;

  //data["projectId"] = firebaseProjectId;

  data['lastUpdate'] = student.lastUpdate;
  data['loadDate'] = student.loadDate;

  return data;
}
void _savePerson(Map<String, dynamic> saveTo, String key, Person person) {
  saveTo["$key-name"] =
      person == null ? "" : "${person.firstName} ${person.lastName}";
  saveTo["$key-email"] = person == null ? "" : person.email;
  saveTo["$key-phone"] = person == null ? "" : person.phoneNumber;
}
Map<String, dynamic> projectToData(Project project) {
  final data = Map<String, dynamic>();
  data['projectSubject'] = project.projectSubject;
  data['projectDomain'] = project.projectDomain;
  data['projectGoal'] = project.projectGoal;
  data['endDate'] = project.endDate;

  _savePerson(data, 'initiator', project.initiator);
  _savePerson(data, 'contact', project.contact);
  _savePerson(data, 'mentor', project.mentor);
   
  data['projectChallenges'] = project.projectChallenges;
  data['projectInnovativeDetails'] = project.projectInnovativeDetails;

  data['projectStatus'] = project.projectStatus;

  data['mentorTechAbility'] = project.mentorTechAbility;

  return data;
}
