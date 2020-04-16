import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/models/data/student.dart';

import 'package:workshop_digitalization/view/forms/types/types.dart';

class StudentForm extends StatefulWidget {
  Student student;

  StudentForm({this.student});

  @override
  _StudentFormState createState() => _StudentFormState();
}

final _dateFormat = DateFormat.yMd().add_Hms();

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();

  String _dropdownValue = "One";

  Widget _dropdown() {
    return DropdownButton<String>(
      value: _dropdownValue,
      underline: Container(
        height: 2,
        color: Colors.amberAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          _dropdownValue = newValue;
        });
      },
      items: <String>['One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  Widget _studentForm(
      {Map<String, dynamic> initials = const {
        "status": StudentStatus.SEARCHING
      }}) {
    return Column(children: <Widget>[
      FormBuilder(
          key: _fbKey,
          initialValue: initials,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                attribute: "id",
                decoration: InputDecoration(labelText: "Person ID"),
                validators: validators.israeliId,
              ),
              FormBuilderTextField(
                attribute: "name",
                decoration: InputDecoration(labelText: "Name"),
                validators: validators.name,
                valueTransformer: valueTransformers.nameFromString,
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
      Row(
        children: <Widget>[
          RaisedButton(
            child: Text("Submit"),
            onPressed: () => _onSubmit(_fbKey),
          ),
          MaterialButton(
            child: Text("Reset"),
            onPressed: () {
              _fbKey.currentState.reset();
            },
          ),
        ],
      )
    ]);
  }

  void _onSubmit(GlobalKey<FormBuilderState> key) {
    if (key.currentState.saveAndValidate()) {
      // add or edit student code
      print(key.currentState.value);
    } else {}
  }

  Map<String, dynamic> _makeInitials(Student s) => {
        "id": s.id,
        "name": "${s.fullName.first} ${s.fullName.last}",
        "phone": s.phoneNumber,
        "email": s.email,
        "year": s.studyYear,
        "status": s.status ?? StudentStatus.SEARCHING,
        "lastUpdate": _dateFormat.format(s.lastUpdate),
        "loadDate": _dateFormat.format(s.loadDate),
      };


  Widget _buildFiles() {
    // FirebaseStorage.instance.ref().
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: widget.student == null
            ? _studentForm()
            : Column(
                children: <Widget>[
                  _studentForm(initials: _makeInitials(widget.student)),
                  // _buildFiles()
                ],
              ),
      ),
    );
  }
}
