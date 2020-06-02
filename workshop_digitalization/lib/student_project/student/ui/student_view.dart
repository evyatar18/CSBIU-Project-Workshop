import 'package:flutter/material.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';
import 'package:workshop_digitalization/student_project/project/dummy_project.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_preview.dart';

import '../student.dart';
import 'student_form_wrapper.dart';

class StudentDetails extends StatelessWidget {
  final Student student;
  final StudentManager studentManager;

  StudentDetails({@required this.student, @required this.studentManager});

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).canvasColor;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${student.firstName} ${student.lastName}"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {},
              child: Icon(Icons.call, color: color),
            ),
            FlatButton(
              onPressed: () {},
              child: Icon(Icons.mail, color: color),
            )
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
            Wrap(
              children: [
                Card(
                  child: ProjectPreview(project: DummyProject()),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
