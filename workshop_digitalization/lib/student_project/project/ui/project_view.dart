import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/firebase_consts/firebase_root.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
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

  ProjectDetailsView({
    @required this.project,
    @required this.projectManager,
    @required this.studentManager,
    @required this.firebaseInstance,
  });

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
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(child: TabName(title: 'Details')),
              Tab(child: TabName(title: 'Memos')),
              Tab(child: TabName(title: 'Documents')),
              Tab(child: TabName(title: 'Students'))
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProjectFormWrapper(
              project: project,
              projectManager: projectManager,
              firebase: firebaseInstance,
            ),
            FutureBuilder<List<String>>(
              future: project.students
                  .then((value) => value.map((e) => e.email).toList()),
              builder: (context, snapshot) {
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
              project: project,
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
  final Project project;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildStudentsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ret = await _openAddStudent(context);

          if (ret != null && ret) {
            // update state because we added a student
            setState(() {});
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<bool> _openAddStudent(BuildContext context) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return StudentTableScreen(
            title: "Choose a Student",
            studentManager: widget.studentManager,
            projectManager: widget.projectManager,
            showAddButton: false,
            onStudentClick: (context, student) async {
              final project = widget.project;
              project.studentIds = project.studentIds..add(student.id);

              try {
                await widget.projectManager.save(project);
                await showSuccessDialog(context,
                    title: "Added student to project successfully.");

                Navigator.pop(context, true);
              } catch (e) {
                await showErrorDialog(context,
                    title: "Error while adding student", error: e.toString());

                Navigator.pop(context, false);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentsList() {
    return FutureBuilder<List<Student>>(
      future: widget.project.students,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LabeledCircularLoader(
            labels: ["Getting Students"],
          );
        }

        return Column(
          children: snapshot.data.map(_buildStudentCard).toList(),
        );
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
            onPressed: () async {
              FlutterEmailSender.send(
                Email(
                  recipients: [student.email],
                  subject: "Project: ${widget.project.projectSubject ?? ""}",
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.project.studentIds = widget.project.studentIds
                ..remove(student.id);
              widget.projectManager
                  .save(widget.project)
                  .then((value) => setState(() {}));
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
