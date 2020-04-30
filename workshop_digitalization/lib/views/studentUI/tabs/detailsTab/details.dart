import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/models/student.dart';

class StudentForm extends StatefulWidget {
  Student student;

  StudentForm({this.student});

  @override
  _StudentFormState createState() => _StudentFormState();
}

final _dateFormat = DateFormat.yMd().add_Hms();

class _StudentFormState extends State<StudentForm> {
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
                  onPressed: () => _onSubmit(_fbKey),
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

  Widget _studentForm(
      {Map<String, dynamic> initials = const {
        "status": StudentStatus.SEARCHING
      },
      bool canRead = false}) {
    return Column(children: <Widget>[
      FormBuilder(
          key: _fbKey,
          initialValue: initials,
          readOnly: canRead,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                attribute: "id",
                decoration: InputDecoration(labelText: "Person ID"),
                //validators: validators.israeliId,
              ),
              FormBuilderTextField(
                attribute: "name",
                decoration: InputDecoration(labelText: "Name"),
                //validators: validators.name,
                //valueTransformer: valueTransformers.nameFromString,
              ),

              // TODO:: add option to choose phone providers
              // multiple phone numbers(?)
              FormBuilderTextField(
                attribute: "phone",
                decoration: InputDecoration(labelText: "Phone Number"),
                validators: [
                  FormBuilderValidators.required(),
                  FormBuilderValidators.pattern(
                    "^\\d+-?\\d+\$",
                    errorText: "a phone may only contain numbers and one dash",
                  )
                ],
              ),
              FormBuilderTextField(
                attribute: "email",
                decoration: InputDecoration(labelText: "email"),
                validators: [
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email()
                ],
              ),
              FormBuilderChoiceChip(
                attribute: "year",
                options: [
                  FormBuilderFieldOption(
                    value: 2020,
                    child: Text("2020"),
                  ),
                  FormBuilderFieldOption(
                    value: 2019,
                    child: Text("2019"),
                  )
                ],
                decoration: InputDecoration(border: InputBorder.none),
                validators: [FormBuilderValidators.required()],
              ),
              FormBuilderChoiceChip(
                attribute: "status",
                options: [
                  FormBuilderFieldOption(
                    value: StudentStatus.SEARCHING,
                    child: Text("Searching"),
                  ),
                  FormBuilderFieldOption(
                    value: StudentStatus.WORKING,
                    child: Text("Working"),
                  ),
                  FormBuilderFieldOption(
                    value: StudentStatus.FINISHED,
                    child: Text("Finished"),
                  ),
                  FormBuilderFieldOption(
                    value: StudentStatus.IRRELEVANT,
                    child: Text("Irrelevant"),
                  ),
                ],
                decoration: InputDecoration(border: InputBorder.none),
                validators: [FormBuilderValidators.required()],
              ),
              FormBuilderTextField(
                attribute: "lastUpdate",
                enabled: false,
                readOnly: true,
                decoration: InputDecoration(labelText: "Last Update"),
                valueTransformer: (value) => _dateFormat.parse(value),
              ),
              FormBuilderTextField(
                attribute: "loadDate",
                enabled: false,
                readOnly: true,
                decoration: InputDecoration(labelText: "Load Date"),
                valueTransformer: (value) => _dateFormat.parse(value),
              )
            ],
          )),
      saveSection(),
    ]);
  }

  void _onSubmit(GlobalKey<FormBuilderState> key) {
    if (key.currentState.saveAndValidate()) {
      // add or edit student code
      print(key.currentState.value);
    } else {}
  }

  Map<String, dynamic> _makeInitials(Student s) => {
        "id": s.personalID,
        "name": "${s.firstName} ${s.lastName}",
        "phone": s.phoneNumber,
        "email": s.email,
        "year": s.studyYear,
        "status": s.status ?? StudentStatus.SEARCHING,
        "lastUpdate": _dateFormat.format(s.lastUpdate),
        "loadDate": _dateFormat.format(s.loadDate),
      };


  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    return Padding(
        padding: EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: widget.student == null
                ? _studentForm()
                : Column(
                    children: <Widget>[
                      ListTile(
                        trailing: FlatButton(
                onPressed: () {
                  openOrExitEdit();
                },
                child:Icon(Icons.edit, color: color)
              ),
                      ),
                      _studentForm(
                          initials: _makeInitials(widget.student),
                          canRead: _readOnly),
                    ],
                  ),
        ));
  }
}
