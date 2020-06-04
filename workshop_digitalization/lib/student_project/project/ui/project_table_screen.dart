import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/global/strings.dart';

import '../project.dart';
import 'project_filterable_table.dart';

class ProjectTableScreen<T extends Project> extends StatelessWidget {
  final ProjectManager<T> projectManager;
  final void Function(BuildContext, Project) onProjectClick;
  final bool showAddButton;

  ProjectTableScreen({
    @required this.projectManager,
    this.onProjectClick = _onProjectClick,
    this.showAddButton = true,
  });

  static void _onProjectClick(BuildContext context, Project project) {
    ProjectManager pm = Provider.of<ProjectManager>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (context) => ProjectDetails(
        //   project: project,
        //   projectManager: pm,
        // ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Builder(
      builder: (context) {
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         NewProjectScreen(projectManager: projectManager),
            //   ),
            // );
          },
          heroTag: randomString(10),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ProjectManager>.value(
      value: projectManager,
      child: Scaffold(
        body: createFilterableProjectsTable(projectManager.projects, onProjectClick),
        floatingActionButton: showAddButton ? _buildAddButton() : null,
      ),
    );
  }
}