import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/firebase_roots/dynamic_root/setup.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/student_project/project/ui/new_project_screen.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_view.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import '../project.dart';
import 'project_filterable_table.dart';

class ProjectTableScreen<T extends Student, S extends Project>
    extends StatelessWidget {
  final StudentManager<T> studentManager;
  final ProjectManager<S> projectManager;
  final void Function(BuildContext, Project) onProjectClick;
  final bool showAddButton;
  final String title;

  ProjectTableScreen({
    this.title = "Projects",
    @required this.studentManager,
    @required this.projectManager,
    this.onProjectClick = _onProjectClick,
    this.showAddButton = true,
  });

  static void _onProjectClick(BuildContext context, Project project) {
    // get the managers
    StudentManager sm = Provider.of<StudentManager>(context, listen: false);
    ProjectManager pm = Provider.of<ProjectManager>(context, listen: false);
    FirebaseInstance firebase =
        Provider.of<FirebaseInstance>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsView(
          project: project,
          studentManager: sm,
          projectManager: pm,
          firebaseInstance: firebase,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Builder(
      builder: (context) {
        final firebase = Provider.of<FirebaseInstance>(context);
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewProjectScreen(
                  projectManager: projectManager,
                  firebase: firebase,
                ),
              ),
            );
          },
          heroTag: makeHerotag(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StudentManager>.value(value: studentManager),
        Provider<ProjectManager>.value(value: projectManager),
      ],
      child: Scaffold(
        body: createFilterableProjectsTable(
          projectManager.projects,
          onProjectClick,
          title,
        ),
        // show the add floting add button only if needed
        floatingActionButton: showAddButton ? _buildAddButton() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
