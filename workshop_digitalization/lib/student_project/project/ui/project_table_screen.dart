import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  ProjectTableScreen({
    @required this.studentManager,
    @required this.projectManager,
    this.onProjectClick = _onProjectClick,
    this.showAddButton = true,
  });

  static void _onProjectClick(BuildContext context, Project project) {
    StudentManager sm = Provider.of<StudentManager>(context, listen: false);
    ProjectManager pm = Provider.of<ProjectManager>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsView(
          project: project,
          studentManager: sm,
          projectManager: pm,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Builder(
      builder: (context) {
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewProjectScreen(projectManager: projectManager),
              ),
            );
          },
          heroTag: randomString(10),
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
        ),
        //floatingActionButton: showAddButton ? _buildAddButton() : null,
        //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

// class ProjectTableScreen<T extends Project> extends StatelessWidget {
//   final ProjectManager<T> projectManager;
//   final void Function(BuildContext, Project) onProjectClick;
//   final bool showAddButton;

//   ProjectTableScreen({
//     @required this.projectManager,
//     this.onProjectClick = _onProjectClick,
//     this.showAddButton = true,
//   });

//   static void _onProjectClick(BuildContext context, Project project) {
//     ProjectManager pm = Provider.of<ProjectManager>(context, listen: false);

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           // builder: (context) => ProjectDetails(
//           //   project: project,
//           //   projectManager: pm,
//           // ),
//           ),
//     );
//   }

//   Widget _buildAddButton() {
//     return Builder(
//       builder: (context) {
//         return FloatingActionButton(
//           child: Icon(Icons.add),
//           onPressed: () {
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(
//             //     builder: (context) =>
//             //         NewProjectScreen(projectManager: projectManager),
//             //   ),
//             // );
//           },
//           heroTag: randomString(10),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Provider<ProjectManager>.value(
//       value: projectManager,
//       child: Scaffold(
//         body: createFilterableProjectsTable(
//             projectManager.projects, onProjectClick),
//         floatingActionButton: showAddButton ? _buildAddButton() : null,
//       ),
//     );
//   }
// }
