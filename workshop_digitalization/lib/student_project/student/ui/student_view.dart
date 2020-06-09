import 'package:flutter/material.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_preview.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_table_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
          title: Text("${student.firstName} ${student.lastName}"),
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
            if (project != null) Card(child: ProjectPreview(project: project)),
            RaisedButton(
              child: Text("Set Project"),
              onPressed: () {
                final projects = ProjectTableScreen(
                  projectManager: projectManager,
                  showAddButton: false,
                  onProjectClick: (context, newProject) async {
                    if (project != null)
                      project.studentIds = project.studentIds
                        ..remove(student.id);
                    newProject.studentIds = newProject.studentIds..add(student.id);

                    await Future.wait([
                      if (project != null) projectManager.save(project),
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
            ),
          ],
        );
      },
    );
  }
}
