import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/json/jsonable.dart';
import 'package:workshop_digitalization/global/json/jsonable_details.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/person/person.dart';
import 'package:workshop_digitalization/student/ui/new_student_view.dart';
import 'package:workshop_digitalization/table/ui/table.dart';

import '../project.dart';

class ProjectTableScreen extends StatelessWidget {
  final List<Project> projects = List<Proj>.generate(10, (i) => Proj());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table'),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewStudentScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: new JsonDataTable(
          jsonableObjects: projects,
          factory: ProjectDetailsFactory(),
        ),
      ),
    );
  }
}

class ProjectDetailsFactory implements JsonableDetailsFactory {
  @override
  JsonableDetails create(Jsonable s) {
    // return new ProjectDetailsView(s);
    throw "NEED TO IMPLEMENT FACTORY";
  }
}

class Proj implements Project {
  @override
  Memo comments;

  @override
  Person contact;

  @override
  DateTime endDate;

  @override
  String initiatorFirstName;

  @override
  String initiatorLastName;

  @override
  Person mentor;

  @override
  String mentorTechAbility;

  @override
  int numberOfStudents;

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
  Proj({
    this.comments,
    this.contact,
    this.endDate,
    this.initiatorFirstName,
    this.initiatorLastName,
    this.mentor,
    this.mentorTechAbility,
    this.numberOfStudents = 3,
    this.projectChallenges,
    this.projectDomain,
    this.projectGoal = 'learninig',
    this.projectInnovativeDetails,
    this.projectSubject = 'ML',
    this.skills,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {};
    m['subject'] = projectSubject;
    m['numberOfStudents'] = numberOfStudents;
    m['goal'] = projectGoal;
    return m;
  }

  @override
  // TODO: implement lastUpdate
  DateTime get lastUpdate => null;

  @override
  // TODO: implement loadDate
  DateTime get loadDate => null;
}
