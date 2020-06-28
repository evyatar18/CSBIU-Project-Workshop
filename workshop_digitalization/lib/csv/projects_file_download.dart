import 'dart:io';

import 'package:csv/csv.dart';
import 'package:directory_picker/directory_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';

import 'csv_utils.dart';
import 'file_IO.dart';

class ProjectsFileDownloader {
  final ProjectManager projectManager;

  ProjectsFileDownloader({
    @required this.projectManager,
  });

  void writeProjectsToFile(BuildContext context) async {
    Directory directory = await DirectoryPicker.pick(
        context: context, rootDirectory: await getExternalStorageDirectory());
    if (directory != null) {
      final path = directory.path;
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
      FileIO.write(path: '$path/projects.csv', data: csv);
      showSuccessDialog(context,message: "The file saved in : $path");
    }
  }
}
