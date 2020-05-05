import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/models/student/student.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/detailsTab/studentForm.dart';

class StudentDetailsForm extends StatefulWidget {
  Student student;

  StudentDetailsForm({this.student});

  @override
  _StudentDetailsFormState createState() => _StudentDetailsFormState();
}

final _dateFormat = DateFormat.yMd().add_Hms();

class _StudentDetailsFormState extends State<StudentDetailsForm> {
  var _readOnly = true;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  void openOrExitEdit() {
    setState(() {
      _readOnly = !_readOnly;
    });
  }

  Widget saveSection() {
    return _readOnly == false
        ? Container(
            child: ButtonBar(
              children: <Widget>[
                RaisedButton(
                  child: Text("Submit"),
                  onPressed: () {
                    _onSubmit(_fbKey);
                    openOrExitEdit();
                  },
                ),
                MaterialButton(
                  child: Text("Reset"),
                  onPressed: () {
                    _fbKey.currentState.reset();
                    openOrExitEdit();
                  },
                ),
              ],
            ),
          )
        : Container();
  }

  void _onSubmit(GlobalKey<FormBuilderState> key) {
    if (key.currentState.saveAndValidate()) {
      // add or edit student code
      print(key.currentState.value);
    } else {}
  }


  Map<String, dynamic> _makeInitials(Student s) => s.toJson();
  // {

  //       // "id": s.personalID,
  //       // "name": "${s.firstName} ${s.lastName}",
  //       // "phone": s.phoneNumber,
  //       // "email": s.email,
  //       // "year": s.studyYear,
  //       // "status": s.status ?? StudentStatus.SEARCHING,
  //       // "lastUpdate": s.lastUpdate!=null ? _dateFormat.format(s.lastUpdate):null,
  //       // "loadDate": s.loadDate!=null? _dateFormat.format(s.loadDate):null,
  //     };

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    return Padding(
        padding: EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: widget.student == null
              ? StudentForm()
              : Column(
                  children: <Widget>[
                    ListTile(
                      title: Text("Edit by clicking"),
                      trailing: FlatButton(
                          onPressed: () {
                            openOrExitEdit();
                          },
                          child: Icon(Icons.edit, color: color)),

                    ),
                    StudentForm(
                        initials: _makeInitials(widget.student),
                        canRead: _readOnly,
                        fbKey: _fbKey),
                    saveSection(),
                  ],
                ),
        ));
  }
}
