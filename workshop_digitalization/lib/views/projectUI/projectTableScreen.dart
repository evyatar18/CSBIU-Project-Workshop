import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/jsonable.dart';
import 'package:workshop_digitalization/models/memo.dart';
import 'package:workshop_digitalization/models/person.dart';
import 'package:workshop_digitalization/models/project.dart';
import 'package:workshop_digitalization/views/projectUI/projectDeatils.dart';
import 'package:workshop_digitalization/views/studentUI/newStudentScreen.dart';
import 'package:workshop_digitalization/views/table/jsonableDetails.dart';
import 'package:workshop_digitalization/views/table/table.dart';

class ProjectTableScreen extends StatelessWidget {
  List<Project> projects = List<Proj>.generate(10, (i)=>Proj()); 
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Table'),
            actions: <Widget>[
              Builder(builder: (context)=>FlatButton(
                child: Icon(Icons.add),
                onPressed:() { 
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewStudentScreen()));
                }) 
              )
            ],
          ),
          body: Center(
              child: new JsonDataTable(
            jsonableObjects: projects,
            factory: ProjectDetailsFactory(),
          ))),
    );
  }
}

class ProjectDetailsFactory implements JsonableDetailsFactory{
  @override
  JsonableDetails create(Jsonable s) {
    return new ProjectDetails(s);
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
    this.numberOfStudents=3,
    this.projectChallenges,
    this.projectDomain,
    this.projectGoal='learninig',
    this.projectInnovativeDetails,
    this.projectSubject= 'ML',
    this.skills,
  });

  
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {};
    m['subject']= projectSubject;
    m['numberOfStudents'] = numberOfStudents;
    m['goal'] = projectGoal;
    return m;
  }
  
}
