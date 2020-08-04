import 'package:flutter/material.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/student_project/ui/new_element_screen.dart';

import '../project.dart';
import '../project_element_manager.dart';
import 'project_form.dart';

class NewProjectScreen extends StatelessWidget {
  final ProjectManager projectManager;
  final FirebaseInstance firebase;

  NewProjectScreen({
    Key key,
    @required this.projectManager,
    @required this.firebase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NewElementScreen<Project>(
        elementManager: ProjectElementManager(projectManager),
        elementName: "project",
        elementFormCreator: ProjectForm.createProjectCreator(firebase),
      ),
    );
  }
}
