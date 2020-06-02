import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/firebase_memo.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';

import '../../student/firebase_student.dart';
import 'project_form_warper.dart';
import '../project.dart';

final dummy_memos =
    FirebaseMemoManager(Flamingo.instance.rootReference.collection("memos"));

class ProjectDetailsView extends StatelessWidget {
  final Project project;
  ProjectDetailsView({@required this.project});

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).canvasColor;
    var f = FirebaseStudent();
    f.memos.createEmpty();
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
              ProjectFormWarper(project: this.project),
              MemoScaffold(
                memoManager: f.memos,
              ),
              Icon(Icons.directions_bike),
              // MemoScaffold(memoManager: dummy_memos),
              Icon(Icons.ac_unit),
            ],
          ),
        ),
      ),
    );
  }
}
