import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/models/data/student.dart';
import 'package:workshop_digitalization/view/forms/validators/name.dart';

import 'forms/validators/israeli_id.dart';

class AddStudentForm extends StatefulWidget {
  Student student;

  AddStudentForm(this.student);

  @override
  _AddStudentFormState createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
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

  Widget _studentForm(Map<String, dynamic> initials) {
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
                  validators: getIsraeliIdValidators()),
              FormBuilderTextField(
                attribute: "name",
                decoration: InputDecoration(labelText: "Name"),
                validators: getNameValidators(),
              )
            ],
          )),
      Row(
        children: <Widget>[
          MaterialButton(
            child: Text("Submit"),
            onPressed: () {
              print("pressed");
              if (_fbKey.currentState.saveAndValidate()) {
                print("hll");
                print(_fbKey.currentState.value);
              } else {
                print("did not validate");
              }
            },
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

  @override
  Widget build(BuildContext context) {
    final stud = widget.student;

    return Padding(
        padding: EdgeInsets.all(18),
        child: SingleChildScrollView(child: _studentForm({})));

    // return Form(
    //     key: _formKey,
    //     child: Column(children: <Widget>[
    //       Text("email"),
    //       TextField(onChanged: (value) {
    //         print(value);
    //         stud.email = value;
    //         print("h");
    //       }),
    //       _dropdown(),
    //       RaisedButton(
    //           onPressed: () {
    //             if (_formKey.currentState.validate()) {
    //               print("Submitted");
    //               Scaffold.of(context)
    //                   .showSnackBar(SnackBar(content: Text('Processing Data')));
    //             }
    //           },
    //           child: Text("Submit"))
    //     ]));
  }
}
