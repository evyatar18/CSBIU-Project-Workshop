import 'package:flutter/material.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import '../project.dart';
import 'project_form_wrapper.dart';

class ProjectDetailsView extends StatelessWidget {
  final Project project;
  final ProjectManager projectManager;
  final StudentManager studentManager;

  ProjectDetailsView({
    @required this.project,
    @required this.projectManager,
    @required this.studentManager,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Project"),
            bottom: TabBar(
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
              ),
              FutureBuilder<List<String>>(
                future: project.students
                    .then((value) => value.map((e) => e.email).toList()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  return MemoScaffold(
                    memoEmailRecipients: snapshot.data,
                    memoManager: project.memos,
                  );
                },
              ),
              createFileContainerDisplayer(container: project.files),
              Icon(Icons.ac_unit),
            ],
          ),
        ),
      ),
    );
  }
}
