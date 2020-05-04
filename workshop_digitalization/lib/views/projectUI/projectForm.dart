import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/models/project.dart';

class ProjectDetailsForm extends StatefulWidget {
  Project project;
  Map<String, dynamic> initials;
  bool canRead = false;
  GlobalKey<FormBuilderState> fbKey;
  ProjectDetailsForm({
    this.project,
    this.initials ,
    this.canRead,
    this.fbKey,
  });
  @override
  State<StatefulWidget> createState() {
    return ProjectDetailsFormState();
  }
}

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
              
            ],
          )
    );
  }
}
