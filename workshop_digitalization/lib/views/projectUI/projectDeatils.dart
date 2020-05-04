

import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/memo.dart';
import 'package:workshop_digitalization/models/project.dart';
import 'package:workshop_digitalization/views/projectUI/projectForm.dart';
import 'package:workshop_digitalization/views/studentUI/studentDetails.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/memosTab/memosUI.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/utils/tabName.dart';
import 'package:workshop_digitalization/views/table/jsonableDetails.dart';

class ProjectDetails extends StatelessWidget implements JsonableDetails{
  Project project ;
  ProjectDetails(this.project);

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
                Tab(child: TabName('Project Details')),
                Tab(child: TabName('Memo\'s')),
                Tab(child: TabName('Documents')),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ProjectDetailsForm(project: this.project,),
              MemoList(memos: new List<Memo>.generate(100, (i) => new Mem())),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}