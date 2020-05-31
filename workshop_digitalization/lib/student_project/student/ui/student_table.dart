import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/json/jsonable.dart';
import 'package:workshop_digitalization/global/json/jsonable_details.dart';
import 'package:workshop_digitalization/student/student.dart';
import 'package:workshop_digitalization/student/ui/new_student_view.dart';
import 'package:workshop_digitalization/student/ui/student_view.dart';
import 'package:workshop_digitalization/table/ui/table.dart';

class TableScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TableScreenState();
  }
}

class TableScreenState extends State<TableScreen> {
  final FirebaseTableBloc _bloc = FirebaseTableBloc();
  List<Student> students =
      List<Student>.generate(100, (i) => throw "no students");

  Widget _buildTable() {
    // return StreamBuilder(
    //   stream: _bloc.dataStream,
    //   builder: (context, snapshot) {
    //     final data = snapshot.data;

    //     if (data == null) {
    //       return Center(
    //           child: SpinKitChasingDots(
    //               color: Theme.of(context).accentColor, size: 80.0));
    //     }

    return new JsonDataTable(
      jsonableObjects: students,
      factory: StudentDetailsFactry(),
    );
    // },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Table'),
          actions: <Widget>[
            Builder(
                builder: (context) => FlatButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewStudentScreen()));
                    }))
          ],
        ),
        body: Center(
          child: _buildTable(),
        ),
      ),
    );
  }
}

class StudentDetailsFactry implements JsonableDetailsFactory {
  @override
  JsonableDetails create(Jsonable s) => StudentDetails(student: s);
}
