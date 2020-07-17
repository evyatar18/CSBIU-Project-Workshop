import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:workshop_digitalization/firebase_consts/lib.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/person/ui/person_form.dart';

import '../project.dart';

class ProjectForm extends StatelessWidget {
  final Project project;
  final bool readOnly;
  final GlobalKey<FormBuilderState> fbKey;

  ProjectForm({
    @required this.project,
    @required this.fbKey,
    this.readOnly = true,
  });

  static ProjectForm elementForm({
    @required Project element,
    @required bool readOnly,
    @required GlobalKey<FormBuilderState> formBuilderKey,
  }) =>
      ProjectForm(
        project: element,
        readOnly: readOnly,
        fbKey: formBuilderKey,
      );
  @override
  Widget build(BuildContext context) {
    Set<String> statuses = Set.from(currentRoot.statuses);

    // in case the project status is not in the written statuses, add it
    statuses.add(project.projectStatus);

    return FormBuilder(
      key: fbKey,
      readOnly: readOnly,
      autovalidate: true,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FormBuilderTextField(
              initialValue: project.projectSubject,
              attribute: 'subject',
              decoration: InputDecoration(labelText: "Subject"),
              onSaved: (subject) => project.projectSubject = subject,
            ),
            FormBuilderTextField(
              initialValue: project.projectDomain,
              attribute: 'domain',
              decoration: InputDecoration(labelText: "Project Domain"),
              onSaved: (domain) => project.projectDomain = domain,
            ),
            FormBuilderTextField(
              initialValue: project.projectGoal,
              attribute: 'goal',
              decoration: InputDecoration(labelText: "Project Goal"),
              onSaved: (goal) => project.projectGoal = goal,
            ),
            FormBuilderDateTimePicker(
              initialDate: project.endDate ?? DateTime.now(),
              attribute: 'endDate',
              inputType: InputType.date,
              format: DateFormat("dd-MM-yyyy"),
              decoration: InputDecoration(labelText: "Expected End Date"),
              onSaved: (dateTime) => project.endDate = dateTime,
            ),
            ExpandablePersonForm(
              person: project.initiator,
              personId: "initiator",
              personTitle: "Initiator",
            ),
            ExpandablePersonForm(
              person: project.contact,
              personId: "contact",
              personTitle: "Contact",
            ),
            ExpandablePersonForm(
              person: project.mentor,
              personId: "mentor",
              personTitle: "Mentor",
            ),
            FormBuilderTextField(
              initialValue: project.mentorTechAbility,
              attribute: 'mentorTechAbility',
              decoration: InputDecoration(labelText: "Mentor Tech Ability"),
              onSaved: (techAbility) => project.mentorTechAbility = techAbility,
            ),
            FormBuilderTextField(
              initialValue: project.numberOfStudents.toString(),
              decoration: InputDecoration(labelText: "Number of students"),
              attribute: 'numberOfStudents',
              readOnly: true,
            ),
            FormBuilderChoiceChip(
              initialValue: project.projectStatus,
              attribute: 'status',
              options: statuses
                  .map((status) => FormBuilderFieldOption(
                      value: status, child: Text(capitalize(status))))
                  .toList(),
              decoration: InputDecoration(
                  border: InputBorder.none, labelText: "Project Status"),
              onSaved: (status) => project.projectStatus = status,
            ),
            FormBuilderTextField(
              initialValue: writeDate(project.lastUpdate),
              attribute: "lastUpdate",
              enabled: false,
              readOnly: true,
              decoration: InputDecoration(labelText: "Last Update"),
            ),
            FormBuilderTextField(
              initialValue: writeDate(project.loadDate),
              attribute: "loadDate",
              enabled: false,
              readOnly: true,
              decoration: InputDecoration(labelText: "Load Date"),
            ),
            FormBuilderTextField(
              initialValue: project.skills,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              attribute: 'skills',
              decoration:
                  InputDecoration(labelText: "Skills needed for the project"),
              onSaved: (skills) {
                project.skills = skills;
              },
            ),
            FormBuilderTextField(
              initialValue: project.comments,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              attribute: 'comments',
              decoration: InputDecoration(labelText: "Comments"),
              onSaved: (comments) => project.comments = comments,
            ),
          ],
        ),
      ),
    );
  }
}
