import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/strings.dart';

import '../project.dart';

class ProjectPreview extends StatelessWidget {
  final Project project;

  ProjectPreview({
    @required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        project.projectSubject ?? "Unnamed Project",
      ),

      subtitle: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Status: ${capitalize(project.projectStatus)}",
            ),
            Text(
              "Number of members: ${project.numberOfStudents}",
            )
          ],
        ),
      ),
    );
  }
}
