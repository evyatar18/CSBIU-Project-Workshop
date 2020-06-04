import 'package:flutter/material.dart';
import 'package:workshop_digitalization/student_project/project/project_element_manager.dart';
import 'package:workshop_digitalization/student_project/ui/edit_element_screen.dart';

import 'project_form.dart';
import '../project.dart';

class ProjectFormWrapper extends StatelessWidget {
  final Project project;
  final ProjectManager projectManager;

  ProjectFormWrapper({
    @required this.project,
    @required this.projectManager,
  });

  @override
  Widget build(BuildContext context) {
    return EditElementForm(
      element: project,
      elementManager: ProjectElementManager(projectManager),
      formCreator: ProjectForm.elementForm,
    );
  }
}
