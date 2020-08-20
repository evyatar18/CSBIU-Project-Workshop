import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/global/validators/validators.dart';
import 'package:workshop_digitalization/person/person.dart';

class ExpandablePersonForm extends StatefulWidget {
  final Person person;
  final String personId;
  final String personTitle;

  ExpandablePersonForm({
    @required this.person,
    @required this.personId,
    @required this.personTitle,
  });

  @override
  _ExpandablePersonFormState createState() => _ExpandablePersonFormState();
}

class _ExpandablePersonFormState extends State<ExpandablePersonForm> {
  bool _isExpanded = false;

  void _setExpanded(bool value) {
    // 
    setState(() {
      _isExpanded = value;
    });
  }

  void _toggleExpansion() {
    // close or open the form
    _setExpanded(!_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionPanelList(
        // call the `_toggleExpansion` function when the expansion button invoked
        expansionCallback: (panelIndex, isExpanded) => _toggleExpansion(),
        children: [
          ExpansionPanel(
            headerBuilder: (context, isExpanded) => ListTile(
              title: Text(widget.personTitle),
              onTap: _toggleExpansion,
            ),
            body: PersonForm2(
              person: widget.person,
              personId: widget.personId,
            ),
            isExpanded: _isExpanded,
          )
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 5),
    );
  }
}

class PersonForm2 extends StatelessWidget {
  final Person person;
  final String personId;

  PersonForm2({
    @required this.person,
    @required this.personId,
  });

  Widget _buildData() {
    return Column(
      children: <Widget>[
        FormBuilderTextField(
          initialValue: person.firstName ?? "",
          attribute: "$personId-firstName",
          decoration: InputDecoration(labelText: "First Name"),
          onSaved: (name) => person.firstName = name,
        ),
        FormBuilderTextField(
          initialValue: person.lastName ?? "",
          attribute: "$personId-lastName",
          decoration: InputDecoration(labelText: "Last Name"),
          onSaved: (name) => person.lastName = name,
        ),
        FormBuilderTextField(
          initialValue: person.phoneNumber ?? "",
          attribute: "$personId-phone",
          decoration: InputDecoration(labelText: "Phone Number"),
          validators: [phoneValidator],
          onSaved: (number) => person.phoneNumber = number,
        ),
        FormBuilderTextField(
          initialValue: person.email ?? "",
          attribute: "$personId-email",
          decoration: InputDecoration(labelText: "email"),
          validators: [
            // FormBuilderValidators.required(),
            FormBuilderValidators.email()
          ],
          onSaved: (email) => person.email = email,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: _buildData(),
    );
  }
}

class PersonForm extends StatefulWidget {
  final Person person;
  final bool canRead;
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

  Widget _buildData() {
    return Column(
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
          keyboardType: TextInputType.phone,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widget.fbKey,
      initialValue: _makeInitials(widget.person),
      readOnly: widget.canRead,
      autovalidate: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: _buildData(),
      ),
    );
  }
}
