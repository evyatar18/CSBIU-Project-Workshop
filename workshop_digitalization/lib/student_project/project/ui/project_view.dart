import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/dynamic_firebase/setup.dart';
import 'package:workshop_digitalization/global/emails.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/global/ui/exception_handler.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_table.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_view.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';

import '../project.dart';
import 'project_form_wrapper.dart';

class ProjectDetailsView extends StatelessWidget {
  final Project project;
  final ProjectManager projectManager;
  final StudentManager studentManager;
  final FirebaseInstance firebaseInstance;
  final Stream<Project> _currentProjectStream;

  ProjectDetailsView({
    @required this.project,
    @required this.projectManager,
    @required this.studentManager,
    @required this.firebaseInstance,
  }) : _currentProjectStream = ReplayConnectableStream(
          projectManager.projects.map(
              (projs) => projs.firstWhere((proj) => proj.id == project.id)),
        )..connect();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Project"),
              Text(
                project.projectSubject == null || project.projectSubject.isEmpty
                    ? "<no subject>"
                    : project.projectSubject,
              )
            ],
          ),
          actions: <Widget>[
            Tooltip(
                message: 'Send an Email',
                child: StreamBuilder(
                  stream: _currentProjectStream.map(
                    (event) => event.students.map((e) => e.email).toList(),
                  ),
                  builder: (context, snapshot) {
                    return FlatButton(
                      // if there is no emails yet , dont do nothing
                      onPressed: !snapshot.hasData
                          ? null
                          : () async {
                              final email = Email(
                                to: snapshot.data,
                                subject:
                                    "Project: ${project?.projectSubject ?? ""}",
                              );

                              handleExceptions(
                                context,
                                email.send(),
                                "Couldn't send email",
                              );
                            },
                      child: snapshot.hasError
                          ? Text("Couldn't get emails")
                          : Icon(
                              Icons.mail,
                              color: Colors.white,
                            ),
                    );
                  },
                )),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(child: TabTitle(title: 'Details')),
              Tab(child: TabTitle(title: 'Memos')),
              Tab(child: TabTitle(title: 'Documents')),
              Tab(child: TabTitle(title: 'Students'))
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // tab of project form that presents the details of the project
            // that can be edited if it neccessery
            ProjectFormWrapper(
              project: project,
              projectManager: projectManager,
              firebase: firebaseInstance,
            ),
            // create memos tab
            StreamBuilder<List<String>>(
              stream: _currentProjectStream.map(
                (event) => event.students.map((e) => e.email).toList(),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  if (snapshot.error is StateError) {
                    return CompletelyCentered(children: [
                      Text(
                        "Cannot show students because project was removed from remote database",
                      )
                    ]);
                  } else {
                    return CompletelyCentered(children: [
                      Text("Error when getting latest project data"),
                      Text(snapshot.error.toString())
                    ]);
                  }
                }
                if (!snapshot.hasData) {
                  return LabeledCircularLoader(
                      labels: ["Getting Student Emails"]);
                }

                return MemoScaffold(
                  memoEmailRecipients: snapshot.data,
                  memoManager: project.memos,
                );
              },
            ),
            createFileContainerDisplayer(container: project.files),
            _StudentsDisplayer(
              project: _currentProjectStream,
              projectManager: projectManager,
              studentManager: studentManager,
              firebase: firebaseInstance,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentsDisplayer extends StatefulWidget {
  final Stream<Project> project;
  final ProjectManager projectManager;
  final StudentManager studentManager;
  final FirebaseInstance firebase;

  _StudentsDisplayer({
    @required this.project,
    @required this.projectManager,
    @required this.studentManager,
    @required this.firebase,
  });

  @override
  _StudentsDisplayerState createState() => _StudentsDisplayerState();
}

class _StudentsDisplayerState extends State<_StudentsDisplayer> {
  Project _project;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.project,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error is StateError) {
            return CompletelyCentered(children: [
              Text(
                "Cannot show students because project was removed from remote database",
              )
            ]);
          } else {
            return CompletelyCentered(children: [
              Text("Error when getting latest project data"),
              Text(snapshot.error.toString())
            ]);
          }
        }

        if (!snapshot.hasData) {
          return LabeledCircularLoader(labels: ["Loading project data..."]);
        }

        _project = snapshot.data;

        return Scaffold(
          body: _buildStudentsList(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddStudent(context),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<bool> _openAddStudent(BuildContext context) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) {
          bool selected = false;

          return StudentTableScreen(
            title: "Choose a Student",
            studentManager: widget.studentManager,
            projectManager: widget.projectManager,
            showAddButton: false,
            onStudentClick: (context, student) async {
              if (selected) {
                return;
              }
              // if the project already contains this student
              if (_project.studentIds.contains(student)) {
                Navigator.pop(context, false);
                return;
              }

              selected = true;

              // add the selected student ID
              _project.studentIds = _project.studentIds..add(student.id);

              try {
                await widget.projectManager.save(_project);
                await showSuccessDialog(
                  context,
                  title: "Added student to project successfully.",
                );

                Navigator.pop(context, true);
              } catch (e) {
                await showErrorDialog(
                  context,
                  title: "Error while adding student",
                  error: e.toString(),
                );

                Navigator.pop(context, false);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentsList() {
    return StreamBuilder<List<Student>>(
      stream: widget.studentManager.students,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LabeledCircularLoader(
            labels: ["Refreshing Students Data"],
          );
        }

        final students = _project.students;
        final studentEmails = students
            .map((e) => e.email)
            .where((email) => email != null)
            .join(",");
        final nullEmails = students.length - studentEmails.length;
        final nullEmailsMessage = nullEmails > 0
            ? "There were $nullEmails students with undefined emails."
            : "";

        return Builder(builder: (context) {
          return Column(
            children: [
              RaisedButton(
                child: Text("Copy Emails"),
                onPressed: () async {
                  try {
                    await Clipboard.setData(ClipboardData(text: studentEmails));

                    showSuccessDialog(
                      context,
                      title: "Copied student emails into clipboard",
                      message: "Emails: $studentEmails\n$nullEmailsMessage",
                    );
                  } catch (e) {
                    showErrorDialog(
                      context,
                      title: "Error copying student emails into clipboard",
                      error: e.toString(),
                    );
                  }
                },
              ),
              ...students.map(_buildStudentCard)
            ],
          );
        });
      },
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      child: InkWell(
        child: _buildStudentTile(student),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetails(
                firebase: widget.firebase,
                student: student,
                projectManager: widget.projectManager,
                studentManager: widget.studentManager,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentTile(Student student) {
    return ListTile(
      title: Text(capitalize("${student.firstName} ${student.lastName}")),
      trailing: Wrap(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.mail),
            onPressed: () {
              final email = Email(
                to: [student.email],
                subject: "Project: ${_project.projectSubject ?? ""}",
              );

              handleExceptions(
                context,
                email.send(),
                "Couldn't send email",
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _project.studentIds = _project.studentIds..remove(student.id);
              widget.projectManager.save(_project);
            },
          )
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(
            height: 4,
          ),
          Text("ID: ${student.personalID}"),
          SizedBox(
            height: 2,
          ),
          Text("Grade: ${student.grade.grade}"),
        ],
      ),
    );
  }
}
