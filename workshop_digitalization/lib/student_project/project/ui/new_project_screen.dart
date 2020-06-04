import 'package:flutter/material.dart';
import 'package:workshop_digitalization/student_project/ui/new_element_screen.dart';

import '../project.dart';
import '../project_element_manager.dart';
import 'project_form.dart';

class NewProjectScreen extends StatelessWidget {
  final ProjectManager studentManager;

  NewProjectScreen({
    Key key,
    @required this.studentManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NewElementScreen<Project>(
      elementManager: ProjectElementManager(studentManager),
      elementName: "project",
      elementFormCreator: ProjectForm.elementForm,
    );
  }
}
