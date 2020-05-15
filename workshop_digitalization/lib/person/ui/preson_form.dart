import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/person/person.dart';

class PersonForm extends StatefulWidget {
  Person person;
  bool canRead = false;
  Map<String, dynamic> initials;
  GlobalKey<FormBuilderState> fbKey;
  PersonForm({
    this.person,
    this.canRead,
    this.fbKey,
  });
  @override
  State<StatefulWidget> createState() {
    return _PersonFromState();
  }
}

class _PersonFromState extends State<PersonForm> {
  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widget.fbKey,
      initialValue: widget.initials,
      readOnly: widget.canRead,
      autovalidate: true,
      child: Column(
        children: <Widget>[
          FormBuilderTextField(
            attribute: "firstName",
            decoration: InputDecoration(labelText: "First Name"),
          ),
          FormBuilderTextField(
            attribute: "lastName",
            decoration: InputDecoration(labelText: "Last Name"),
          ),
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
        ],
      ),
    );
  }
}
