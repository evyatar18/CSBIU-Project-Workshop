import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:workshop_digitalization/models/student.dart';

class StudentForm extends StatefulWidget {
  Map<String, dynamic> initials;
  bool canRead = false;
  GlobalKey<FormBuilderState> fbKey;
  StudentForm({
    this.initials = const {"status": StudentStatus.SEARCHING, 'year': 2020},
    this.canRead,
    this.fbKey,
  });
  @override
  State<StatefulWidget> createState() {
    return _StudentFromState();
  }
}

final _dateFormat = DateFormat.yMd().add_Hms();

class _StudentFromState extends State<StudentForm> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      FormBuilder(
          key: widget.fbKey,
          initialValue: widget.initials,
          readOnly: widget.canRead,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                attribute: 'id',
                decoration: InputDecoration(labelText: "Person ID"),
                //validators: validators.israeliId,
              ),
              FormBuilderTextField(
                attribute: "firstName",
                decoration: InputDecoration(labelText: "First Name"),
              ),
              FormBuilderTextField(
                attribute: "lastName",
                decoration: InputDecoration(labelText: "Last Name"),
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
              FormBuilderTouchSpin(
                decoration: InputDecoration(labelText: "Stepper"),
                attribute: 'year',
                step: 1,
                addIcon: Icon(Icons.arrow_right),
                subtractIcon: Icon(Icons.arrow_left),
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
              ),
            ],
          ))
    ]);
  }
}
