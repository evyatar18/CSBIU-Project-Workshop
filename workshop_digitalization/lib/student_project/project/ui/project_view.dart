import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';

import '../project.dart';
import 'project_form_wrapper.dart';

class ProjectDetailsView extends StatelessWidget {
  final Project project;
  final ProjectManager projectManager;

  ProjectDetailsView({
    @required this.project,
    @required this.projectManager,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(child: TabName(title: 'Project Details')),
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
              MemoScaffold(
                memoManager: project.memos,
              ),
              Icon(Icons.directions_bike),
              Icon(Icons.ac_unit),
            ],
          ),
        ),
      ),
    );
  }
}
