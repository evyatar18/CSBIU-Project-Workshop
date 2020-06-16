import 'package:flutter/material.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_preview.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_table_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_view.dart';

import '../student.dart';
import 'student_form_wrapper.dart';

class StudentDetails extends StatelessWidget {
  final Student student;
  final StudentManager studentManager;
  final ProjectManager projectManager;

  StudentDetails({
    @required this.student,
    @required this.studentManager,
    @required this.projectManager,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).canvasColor;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text("Student (${student.firstName} ${student.lastName})"),
              Text("", style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
          actions: <Widget>[
            Tooltip(
              message: 'Call',
              child: FlatButton(
                onPressed: () async {
                  await launch('tel:${student.phoneNumber}');
                },
                child: Icon(Icons.call, color: color),
              ),
            ),
            Tooltip(
              message: 'Send an Email',
              child: FlatButton(
                onPressed: () async {
                  await launch('mailto:${student.email}');
                },
                child: Icon(Icons.mail, color: color),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(child: TabName(title: 'Details')),
              Tab(child: TabName(title: 'Memos')),
              Tab(child: TabName(title: 'Documents')),
              Tab(child: TabName(title: 'Project')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StudentDetailsForm(
              student: student,
              studentManager: studentManager,
            ),
            MemoScaffold(
              memoManager: student.memos,
              memoEmailRecipients: [student.email ?? ""],
            ),
            createFileContainerDisplayer(container: student.files),
            _buildProjectView(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectView() {
    return FutureBuilder<Project>(
      future: student.project,
      initialData: null,
      builder: (context, snapshot) {
        final project = snapshot.data;

        return Wrap(
          spacing: 8,
          children: [
            if (project != null) _projectCard(context, project),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _setProjectButton(context, project),
                //if (project != null) _deleteProject(context, project),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _projectCard(BuildContext context, Project project) {
    return Card(
      child: InkWell(
        child: ProjectPreview(project: project),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ProjectDetailsView(
                  project: project,
                  projectManager: projectManager,
                  studentManager: studentManager,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteFromProject(Project project) async {
    project.studentIds = project.studentIds..remove(student.id);
    await projectManager.save(project);
  }

  Widget _setProjectButton(BuildContext context, Project currentProject) {
    return RaisedButton(
      child: Text("Set Project"),
      onPressed: () {
        final projects = ProjectTableScreen(
          studentManager: studentManager,
          projectManager: projectManager,
          showAddButton: false,
          onProjectClick: (context, newProject) async {
            if (currentProject != null)
              currentProject.studentIds = currentProject.studentIds
                ..remove(student.id);
            newProject.studentIds = newProject.studentIds..add(student.id);

            await Future.wait([
              if (currentProject != null) _deleteFromProject(currentProject),
              projectManager.save(newProject)
            ]);

            await showAlertDialog(
              context,
              "Success!",
              "Set project successfully",
            );

            // close project table
            Navigator.pop(context);

            // close student view (so we refresh the student project)
            Navigator.pop(context);
          },
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => projects),
        );
      },
    );
  }

  Widget _deleteProject(BuildContext context, Project project) {
    return RaisedButton(
        child: Text("Remove From Project"),
        onPressed: () async {
          bool del = await showAgreementDialog(context, "Are you sure?");

          if (del == null || !del) {
            return;
          }

          try {
            await _deleteFromProject(project);
            await studentManager.save(student);

            showSuccessDialog(
              context,
              message: "Removed from project successfully",
            );
          } catch (e) {
            showErrorDialog(
              context,
              title: "Failed removing from project",
              error: e.toString(),
            );
          }
        });
  }
}
