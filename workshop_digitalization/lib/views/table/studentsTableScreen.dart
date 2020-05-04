import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:workshop_digitalization/bloc/table_bloc.dart';
import 'package:workshop_digitalization/models/jsonable.dart';
import 'package:workshop_digitalization/models/student.dart';
import 'package:workshop_digitalization/views/studentUI/newStudentScreen.dart';
import 'package:workshop_digitalization/views/studentUI/studentDetails.dart';
import 'package:workshop_digitalization/views/table/jsonableDetails.dart';
import 'package:workshop_digitalization/views/table/table.dart';

class TableScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TableScreenState();
  }
}

class TableScreenState extends State<TableScreen> {
  final FirebaseTableBloc _bloc = FirebaseTableBloc();
  List<Student> students = List<Student>.generate(100, (i) => new Stud());

  Widget _buildTable() {
    return StreamBuilder(
      stream: _bloc.dataStream,
      builder: (context, snapshot) {
        final data = snapshot.data;

        if (data == null) {
          return Center(
              child: SpinKitChasingDots(
                  color: Theme.of(context).accentColor, size: 80.0));
        }

        return new JsonDataTable(
            jsonableObjects: data,
            factory: StudentDetailsFactry(),
          );
      },
    );
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
  JsonableDetails create(Jsonable s) {
    return new StudentDetails(s);
  }
}
