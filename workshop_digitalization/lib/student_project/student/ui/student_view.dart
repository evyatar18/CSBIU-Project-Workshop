import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:html_editor/html_editor.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_preview.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_table_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_view.dart';
import 'package:workshop_digitalization/student_project/student/student_element_manager.dart';
import 'package:workshop_digitalization/student_project/ui/edit_element_screen.dart';

import '../student.dart';
import 'student_form_wrapper.dart';

class StudentDetails extends StatelessWidget {
  final Student student;
  final StudentManager studentManager;
  final ProjectManager projectManager;

  final GlobalObjectKey<HtmlEditorState> _htmlKey;

  StudentDetails({
    @required this.student,
    @required this.studentManager,
    @required this.projectManager,
  }) : _htmlKey =
            GlobalObjectKey<HtmlEditorState>("${student.id}-grade-editor");

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).canvasColor;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Icon(Icons.person),
                  SizedBox(width: 10),
                  Text("Student")
                ],
              ),
              Text(
                capitalize("${student.firstName} ${student.lastName}"),
                style: Theme.of(context)
                    .textTheme
                    .headline
                    .apply(color: Colors.white),
              ),
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
            isScrollable: true,
            tabs: [
              Tab(child: TabName(title: 'Details')),
              Tab(child: TabName(title: 'Grade')),
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
            _buildGradeView(),
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

  Widget _buildGradeView() {
    return EditElementForm(
      enableDeleting: false,
      element: student,
      elementManager: StudentElementManager(studentManager),
      formCreator: ({Student element, formBuilderKey, readOnly}) {
        return FormBuilder(
          key: formBuilderKey,
          initialValue: <String, dynamic>{},
          readOnly: readOnly,
          child: Column(
            children: <Widget>[
              FormBuilderSlider(
                decoration: InputDecoration(labelText: "Grade"),
                attribute: "grade-grade",
                min: 0,
                max: 100,
                initialValue: element.grade.grade,
                divisions: 100,
                onSaved: (val) =>
                    element.grade.grade = num.parse(val.toString()),
              ),
              SizedBox(height: 20),
              FormBuilderTextField(
                decoration: InputDecoration(labelText: "Comments"),
                attribute: "grade-comments",
                onSaved: (value) => element.grade.comments = value,
                initialValue: element.grade.comments,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ],
          ),
        );
      },
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
                if (project != null) _deleteProject(context, project),
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

  Future<void> _deleteFromProject(Project project) {
    project.studentIds = project.studentIds..remove(student.id);
    return projectManager.save(project);
  }

  Widget _setProjectButton(BuildContext context, Project currentProject) {
    return RaisedButton(
      child: Text("Set Project"),
      onPressed: () {
        final projects = ProjectTableScreen(
          title: "Choose a Project",
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
          print("did not delete");
          return;
        }

        try {
          await _deleteFromProject(project);
          // await studentManager.save(student);

          await showSuccessDialog(
            context,
            message: "Removed from project successfully",
          );

          // close student view for refresh
          Navigator.pop(context);
        } catch (e) {
          showErrorDialog(
            context,
            title: "Failed removing from project",
            error: e.toString(),
          );
        }
      },
    );
  }
}
