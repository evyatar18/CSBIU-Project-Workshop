import 'package:flutter/material.dart';
import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/person/person.dart';

import '../../student/student.dart';
import '../../student/ui/new_student_view.dart';
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
      // body: Center(
      //   child: new JsonDataTable(
      //     jsonableObjects: projects,
      //     factory: ProjectDetailsFactory(),
      //   ),
      // ),
    );
  }
}

class Proj implements Project {
  @override
  String comments;

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
  String skills;
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
  // TODO: implement lastUpdate
  DateTime get lastUpdate => null;

  @override
  // TODO: implement loadDate
  DateTime get loadDate => null;

  @override
  List<String> studentIds;

  @override
  // TODO: implement id
  String get id => null;

  @override
  // TODO: implement files
  FileContainer get files => throw UnimplementedError();

  @override
  // TODO: implement memos
  MemoManager<Memo> get memos => throw UnimplementedError();

  @override
  // TODO: implement students
  Future<List<Student>> get students => throw UnimplementedError();
}