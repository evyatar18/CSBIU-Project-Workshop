import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/json/jsonable_details.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/memo.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';
import 'package:workshop_digitalization/project/ui/project_form_warper.dart';

import '../project.dart';
import 'project_form.dart';

class ProjectDetailsView extends StatelessWidget implements JsonableDetails {
  final Project project;
  ProjectDetailsView({@required this.project});

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).canvasColor;

    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(child: TabName(title: 'Project Details')),
                Tab(child: TabName(title: 'Memos')),
                Tab(child: TabName(title: 'Documents')),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ProjectFormWarper(project: this.project),
              MemosListView(
                  ),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}
