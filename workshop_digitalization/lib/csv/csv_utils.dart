import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

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

Map<String, dynamic> projectToData(Project project) {
  final data = Map<String, dynamic>();

  data['initiator'] = project.initiator.firstName + project.initiator.lastName;
  data['initiatorPhone'] = project.contact.phoneNumber;
  data['initiatorEmail'] = project.contact.email;
  data['contact'] = project.contact.firstName + project.contact.lastName;
  data['contactPhone'] = project.contact.phoneNumber;
  data['contactEmail'] = project.contact.email;

  data['projectSubject'] = project.projectSubject;
  data['projectDomain'] = project.projectDomain;
  data['projectGoal'] = project.projectGoal;
  data['endDate'] = project.endDate;

  data['mentor'] = project.mentor;
  data['projectChallenges'] = project.projectChallenges;
  data['projectInnovativeDetails'] = project.projectInnovativeDetails;

  data['projectStatus'] = project.projectStatus;

  data['mentorTechAbility'] = project.mentorTechAbility;

  //data['studentIds'] = project.studentIds;

  // // PROBLEMATIC
  // data['comments'] = project.comments;
  // // PROBLEMATIC
  // data['skills'] = project.skills;

  return data;
}
