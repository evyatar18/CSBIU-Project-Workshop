import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/global/emails.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/global/ui/exception_handler.dart';
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
  final FirebaseInstance firebase;

  StudentDetails({
    @required this.student,
    @required this.studentManager,
    @required this.projectManager,
    @required this.firebase,
  });

  @override
  Widget build(BuildContext context) {

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
                child: Icon(Icons.call,color: Colors.white,),
              ),
            ),
            Tooltip(
              message: 'Send an Email',
              child: FlatButton(
                onPressed: () {
                  handleExceptions(
                    context,
                    Email(to: [student.email]).send(),
                    "Couldn't send email",
                  );
                },
                child: Icon(Icons.mail,color: Colors.white),
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
            _ProjectView(
              student: student,
              studentManager: studentManager,
              projectManager: projectManager,
              firebase: firebase,
            ),
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
      formCreator: (
          {Student element, formBuilderKey, readOnly, initialValues}) {
        return FormBuilder(
          key: formBuilderKey,
          initialValue: initialValues ?? {},
          readOnly: readOnly,
          child: Column(
            children: <Widget>[
              FormBuilderSlider(
                decoration: InputDecoration(labelText: "Grade"),
                attribute: "grade-grade",
                min: 0.0,
                max: 100.0,
                initialValue: element.grade.grade.toDouble(),
                divisions: 100,
                numberFormat: NumberFormat("#"),
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
}

class _ProjectView extends StatefulWidget {
  final Student student;
  final StudentManager studentManager;
  final ProjectManager projectManager;
  final FirebaseInstance firebase;

  _ProjectView({
    @required this.student,
    @required this.studentManager,
    @required this.projectManager,
    @required this.firebase,
  });

  @override
  __ProjectViewState createState() => __ProjectViewState();
}

class __ProjectViewState extends State<_ProjectView> {
  Student student;
  StudentManager get studentManager => widget.studentManager;
  ProjectManager get projectManager => widget.projectManager;
  FirebaseInstance get firebase => widget.firebase;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Student>(
      stream: widget.studentManager.students.asyncMap(
        (studs) => studs.firstWhere(
          (element) => element.id == widget.student.id,
        ),
      ),
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error is StateError) {
            return CompletelyCentered(children: [
              Text("Student has been deleted from remote database"),
              Text("Cannot show project"),
            ]);
          } else {
            return CompletelyCentered(children: [
              Text("An unexpected error occurred"),
              Text(snapshot.error.toString()),
            ]);
          }
        }

        if (!snapshot.hasData) {
          return LabeledCircularLoader(labels: ["Loading Project..."]);
        }

        final student = snapshot.data;
        final project = student.project;
        this.student = student;

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
                  firebaseInstance: firebase,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _setProjectButton(BuildContext context, Project currentProject) {
    return RaisedButton(
      child: Text("Set Project"),
      onPressed: () {
        bool clicked = false;

        final projects = ProjectTableScreen(
          title: "Choose a Project",
          studentManager: studentManager,
          projectManager: projectManager,
          showAddButton: false,
          onProjectClick: (context, newProject) async {
            if (clicked) {
              return;
            }

            clicked = true;

            final changedProject = newProject?.id != currentProject?.id;

            // changed a project
            if (changedProject) {
              newProject.studentIds = newProject.studentIds..add(student.id);

              try {
                await projectManager.save(newProject);

                await showAlertDialog(
                  context,
                  "Success!",
                  "Set project successfully",
                );
              } catch (e, stack) {
                await showErrorDialog(
                  context,
                  title: "Error when changing project",
                  error: "$e\nstacktrace: $stack",
                );
              }
            }

            // close project table
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

  Future<void> _deleteFromProject(Project project) {
    project.studentIds = project.studentIds..remove(student.id);
    return projectManager.save(project);
  }

  Widget _deleteProject(BuildContext context, Project project) {
    bool deleting = false;

    return RaisedButton(
      child: Text("Remove From Project"),
      onPressed: () async {
        if (deleting) {
          return;
        }

        bool del = await showAgreementDialog(context, "Are you sure?");

        if (del == null || !del) {
          print("did not delete");
          return;
        }

        deleting = true;

        try {
          await _deleteFromProject(project);
          // await studentManager.save(student);

          await showSuccessDialog(
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

        deleting = false;
      },
    );
  }
}
