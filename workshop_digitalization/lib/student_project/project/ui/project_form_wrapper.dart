import 'package:flutter/material.dart';
import 'package:workshop_digitalization/dynamic_firebase/setup.dart';
import 'package:workshop_digitalization/student_project/project/project_element_manager.dart';
import 'package:workshop_digitalization/student_project/ui/edit_element_screen.dart';

import 'project_form.dart';
import '../project.dart';

class ProjectFormWrapper extends StatelessWidget {
  final Project project;
  final ProjectManager projectManager;
  final FirebaseInstance firebase;

  ProjectFormWrapper({
    @required this.project,
    @required this.projectManager,
    @required this.firebase,
  });

  @override
  Widget build(BuildContext context) {
    return EditElementForm(
      element: project,
      elementManager: ProjectElementManager(projectManager),
      formCreator: ProjectForm.createProjectCreator(firebase),
    );
  }
}
