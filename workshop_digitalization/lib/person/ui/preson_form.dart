import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/person/person.dart';

class PersonForm extends StatefulWidget {
  final Person person;
  final bool canRead ;
  final GlobalKey<FormBuilderState> fbKey;
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
  Map<String, dynamic> _makeInitials(Person person) {
    return {
      "firstName": person.firstName,
      "lastName": person.lastName,
      "phone": person.phoneNumber,
      "email": person.email,
      
    };
  }
  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widget.fbKey,
      initialValue: _makeInitials(widget.person),
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
