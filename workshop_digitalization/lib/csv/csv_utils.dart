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
  if (student.status != null) data["status"] = student.status.index;
  //data["projectId"] = firebaseProjectId;

  data['lastUpdate'] = student.lastUpdate;
  data['loadDate'] = student.loadDate;

  return data;
}

//TODO: implement the function
Map<String, dynamic> projectToData(Project project) {
  final data = Map<String, dynamic>();

  data['initiator'] = project.initiator;
  data['contact'] = project.contact;
  data['projectSubject'] = project.projectSubject;
  data['projectDomain'] = project.projectDomain;
  data['projectGoal'] = project.projectGoal;
  data['endDate'] = project.endDate;

  data['mentor'] = project.mentor;
  data['projectChallenges'] = project.projectChallenges;
  data['projectInnovativeDetails'] = project.projectInnovativeDetails;

  data['projectStatus'] =
      (project.projectStatus ?? DEFAULT_PROJECT_STATUS).index;

  data['mentorTechAbility'] = project.mentorTechAbility;

  data['studentIds'] = project.studentIds;

  // // PROBLEMATIC
  // data['comments'] = project.comments;
  // // PROBLEMATIC
  // data['skills'] = project.skills;

  return data;
}
