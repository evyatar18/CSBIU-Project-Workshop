import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:workshop_digitalization/person/ui/preson_form.dart';

import '../project.dart';

class ProjectDetailsForm extends StatefulWidget {
  Project project;
  Map<String, dynamic> initials;
  bool canRead = false;
  GlobalKey<FormBuilderState> fbKey;
  ProjectDetailsForm({
    this.project,
    this.initials,
    this.canRead,
    this.fbKey,
  });
  @override
  State<StatefulWidget> createState() {
    return ProjectDetailsFormState();
  }
}

final _dateFormat = DateFormat.yMd().add_Hms();

class ProjectDetailsFormState extends State<ProjectDetailsForm> {
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
            attribute: 'initiator',
            decoration: InputDecoration(labelText: "Initiator"),
          ),
          Card(
            child: PersonForm(
              fbKey: widget.fbKey,
              canRead: widget.canRead,
              person: widget.project.mentor,
            ),
          ),
          FormBuilderTextField(
            attribute: 'subject',
            decoration: InputDecoration(labelText: "Subject"),
          ),
          FormBuilderTextField(
            attribute: 'domain',
            decoration: InputDecoration(labelText: "Project Domain"),
          ),
          FormBuilderTextField(
            attribute: 'goal',
            decoration: InputDecoration(labelText: "Project Goal"),
          ),
          FormBuilderTextField(
            attribute: 'endDate',
            decoration: InputDecoration(labelText: "Excepted end Date"),
          ),
          FormBuilderTouchSpin(
            attribute: 'numberOfStudents',
            decoration: InputDecoration(labelText: "Number of students"),
            step: 1,
            addIcon: Icon(Icons.arrow_right),
            subtractIcon: Icon(Icons.arrow_left),
          ),
          Card(
            child: PersonForm(
              fbKey: widget.fbKey,
              canRead: widget.canRead,
              person: widget.project.mentor,
            ),
          ),
          FormBuilderTextField(
            attribute: 'mentorTechAbility',
            decoration: InputDecoration(labelText: "Mentor Tech Ability"),
            //validators: validators.israeliId,
          ),
          FormBuilderChoiceChip(
            attribute: 'status',
            options: [
              FormBuilderFieldOption(
                value: ProjectStatus.CONTINUE,
                child: Text('New'),
              ),
              FormBuilderFieldOption(
                value: ProjectStatus.CONTINUE,
                child: Text('Continue'),
              )
            ],
            decoration: InputDecoration(border: InputBorder.none),
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
      ),
    );
  }
}
