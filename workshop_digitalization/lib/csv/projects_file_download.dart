
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/download/download_file.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';

import 'csv_utils.dart';

class ProjectsFileDownloader {
  final ProjectManager projectManager;

  ProjectsFileDownloader({
    @required this.projectManager,
  });

  void writeProjectsToFile(BuildContext context) async {
    List<Project> projects = (projectManager.latestProjects);
    List<List<dynamic>> rows = projects
        .map((s) => projectToData(s))
        .toList()
        .map((r) => r.values.toList())
        .toList();
    List<dynamic> topics =
        projects.map((s) => projectToData(s)).toList()[0].keys.toList();
    rows.insert(0, topics);
    String csv = const ListToCsvConverter().convert(rows);
    DownloadFile.download(csv, "projects.csv");
  }
}
