import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/blocs/table_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workshop_digitalization/models/data/name.dart';
import 'package:workshop_digitalization/view/student_form.dart';
import 'package:workshop_digitalization/view/student_table.dart';

import 'models/data/student.dart';
import 'package:workshop_digitalization/loadScreen.dart';
import 'package:workshop_digitalization/models/data/repository/dataRepository.dart';
import 'package:workshop_digitalization/models/data/repository/singleDataRepsitory.dart';
import 'package:workshop_digitalization/models/data/student.dart';

void main() => runApp(new LoadScreen());
final DataRepository repository = SingleDataRepository("students");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Students',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Students'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class MockStudent implements Student {
  @override
  String email = "test@ho.com";

  @override
  Name fullName = Name(first: "hey", last: "world");

  @override
  String id = "123456782";

  @override
  DateTime lastUpdate = DateTime.now().add(Duration(seconds: 10));

  @override
  DateTime loadDate = DateTime.now();

  @override
  String phoneNumber = "123-123123";

  @override
  StudentStatus status = StudentStatus.IRRELEVANT;

  @override
  int studyYear = 2020;

  @override
  DocumentReference reference;

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return null;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Firestore fs = Firestore.instance;
    // fs
    //     .collection("students")
    //     .document("04Vzpzh63aZhl6ywWyVu")
    //     .get()
    //     .asStream()
    //     .expand((ds) => mapFlattener(ds.data).entries)
    //     .forEach(print);

    // var fname = "name.first";

    // fs
    //     .collection("students")
    //     .where(fname, isEqualTo: "x")
    //     .snapshots()
    //     .expand((ds) => ds.documentChanges)
    //     .where((dc) => dc.newIndex >= 0)
    //     .map((dc) => dc.document)
    //     .map((ds) => "${ds.documentID}, ${flattenMap(ds.data)}}")
    //     .forEach(print);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // body: StudentForm(student: _MockStudent())
      body: _buildStudentTable(),
    );
  }
}

Widget _buildStudentTable() => StudentTable(
      FirebaseSchema({
        "name.first": "First Name",
        "name.last": "Last Name",
        "id": "ID",
        "year": "Year",
        "email": "Email",
        "phone": "Phone",
        "status": "Status",
        "lastUpdate": "Last Update",
        "loadDate": "Load Date"
      }),
    );
