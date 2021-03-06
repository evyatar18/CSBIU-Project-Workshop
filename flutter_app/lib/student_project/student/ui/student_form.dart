import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/global/validators/israeli_id.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/global/validators/validators.dart';

import '../student.dart';

String _israeliIdValidator(dynamic candidate) {
  if (!(candidate is String)) {
    return "Candidate for Israeli ID must be a string.";
  }

  try {
    israeliIDChecker(candidate);
  } catch (e) {
    return e.toString();
  }

  return null;
}

final _israeliIdValidators = [
  FormBuilderValidators.numeric(),
  _israeliIdValidator
];

class StudentForm extends StatelessWidget {
  final Student student;
  final bool readOnly;
  final GlobalKey<FormBuilderState> formBuilderKey;
  final Map<String, dynamic> initials;

  StudentForm({
    this.student,
    this.readOnly = false,
    this.formBuilderKey,
    this.initials = const {},
  });

  static StudentForm elementForm({
    @required Student element,
    @required bool readOnly,
    @required GlobalKey<FormBuilderState> formBuilderKey,
    Map<String, dynamic> initialValues,
  }) =>
      StudentForm(
          student: element,
          readOnly: readOnly,
          formBuilderKey: formBuilderKey,
          initials: initialValues);

  Map<String, dynamic> _makeInitials(Student s) {
    return {
      "id": s.personalID,
      "firstName": s.firstName,
      "lastName": s.lastName,
      "phone": s.phoneNumber,
      "email": s.email,
      "year": s.studyYear,
      "status": s.status,
      "lastUpdate": writeDate(s.lastUpdate),
      "loadDate": writeDate(s.loadDate),
      ...(initials ?? {}),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: new EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          FormBuilder(
            key: formBuilderKey,
            initialValue: _makeInitials(student),
            readOnly: readOnly,
            autovalidate: true,
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  attribute: 'id',
                  decoration: InputDecoration(labelText: "Person ID"),
                  validators: _israeliIdValidators,
                  onSaved: (id) => student.personalID = id,
                ),
                FormBuilderTextField(
                  attribute: "firstName",
                  decoration: InputDecoration(labelText: "First Name"),
                  onSaved: (firstName) => student.firstName = firstName,
                ),
                FormBuilderTextField(
                  attribute: "lastName",
                  decoration: InputDecoration(labelText: "Last Name"),
                  onSaved: (lastName) => student.lastName = lastName,
                ),

                FormBuilderTextField(
                  keyboardType: TextInputType.phone,
                  attribute: "phone",
                  decoration: InputDecoration(labelText: "Phone Number"),
                  // validate the phone number 
                  validators: [phoneValidator],
                  onSaved: (phone) => student.phoneNumber = phone,
                ),
                FormBuilderTextField(
                  attribute: "email",
                  decoration: InputDecoration(labelText: "email"),
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email()
                  ],
                  onSaved: (email) => student.email = email,
                ),
                FormBuilderTouchSpin(
                  decoration: InputDecoration(labelText: "Student Year"),
                  attribute: 'year',
                  step: 1,
                  addIcon: Icon(Icons.arrow_right),
                  subtractIcon: Icon(Icons.arrow_left),
                  onSaved: (year) => student.studyYear = year,
                ),

                FormBuilderChoiceChip(
                  attribute: "status",
                  options: StudentStatus.values
                      .map(
                        (status) => FormBuilderFieldOption(
                          value: status,
                          child: Text(capitalize(studentStatusText(status))),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(border: InputBorder.none),
                  validators: [FormBuilderValidators.required()],
                  onSaved: (status) => student.status = status,
                ),
                FormBuilderTextField(
                  attribute: "lastUpdate",
                  enabled: false,
                  readOnly: true,
                  decoration: InputDecoration(labelText: "Last Update"),
                ),
                FormBuilderTextField(
                  attribute: "loadDate",
                  enabled: false,
                  readOnly: true,
                  decoration: InputDecoration(labelText: "Load Date"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
