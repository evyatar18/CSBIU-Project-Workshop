import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:workshop_digitalization/person/ui/preson_form.dart';

import '../project.dart';

class ProjectDetailsForm extends StatefulWidget {
  final Project project;
  final bool canRead ;
  final GlobalKey<FormBuilderState> fbKey ;
  ProjectDetailsForm({
    this.project,
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
  ExapndableItem mentorForm;
  ExapndableItem contantForm;
  void initState() {
    super.initState();
    mentorForm = ExapndableItem(
      headerValue: 'Mentor',
      inner: Card(
        child: PersonForm(
          fbKey: GlobalKey<FormBuilderState>(),
          canRead: widget.canRead,
          person: widget.project.mentor,
        ),
      ),
    );
    contantForm = ExapndableItem(
      headerValue: 'Contant',
      inner: Card(
        child: PersonForm(
          fbKey: GlobalKey<FormBuilderState>(),
          canRead: widget.canRead,
          person: widget.project.contact,
        ),
      ),
    );
  }

  Map<String, dynamic> _makeInitials(Project project) {
    return {
      "subject": project.projectSubject,
      "initiatorFirstName": project.initiatorFirstName,
      "initiatorLastName": project.initiatorLastName,
      "domain": project.projectDomain,
      "goal": project.projectGoal,
      "endDate": project.endDate,
      "status": project.projectStatus,
      'numberOfStudents': project.numberOfStudents,
      'mentorTechAbility': project.mentorTechAbility,
      "lastUpdate": project.lastUpdate.toString(),
      "loadDate": project.loadDate.toString()
    };
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widget.fbKey,
      initialValue: _makeInitials(widget.project),
      readOnly: widget.canRead,
      autovalidate: true,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FormBuilderTextField(
              attribute: 'initiatorFirstName',
              decoration: InputDecoration(labelText: "Initiator First Name"),
            ),
            FormBuilderTextField(
              attribute: 'initiatorLastName',
              decoration: InputDecoration(labelText: "Initiator Last Name"),
            ),
            expandedPanel(contantForm),
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
              decoration: InputDecoration(labelText: "Number of students"),
              attribute: 'numberOfStudents',
              step: 1,
              addIcon: Icon(Icons.arrow_right),
              subtractIcon: Icon(Icons.arrow_left),
            ),
            expandedPanel(mentorForm),
            FormBuilderTextField(
              attribute: 'mentorTechAbility',
              decoration: InputDecoration(labelText: "Mentor Tech Ability"),
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
              decoration: InputDecoration(
                  border: InputBorder.none, labelText: "Project Status"),
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
      ),
    );
  }

  Widget expandedPanel(ExapndableItem item) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          item.isExpanded = !isExpanded;
        });
      },
      children: [
        ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item.headerValue),
              );
            },
            body: item.inner,
            isExpanded: item.isExpanded)
      ],
    );
  }
}

class ExapndableItem {
  Widget inner;
  String headerValue;
  bool isExpanded;
  ExapndableItem({
    this.inner,
    this.headerValue,
    this.isExpanded = false,
  });
}
