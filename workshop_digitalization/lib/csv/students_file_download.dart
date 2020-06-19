import 'dart:io';

import 'package:csv/csv.dart';
import 'package:directory_picker/directory_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import 'csv_utils.dart';
import 'file_IO.dart';

class StudentsFileDownloader {
  final StudentManager studentManager;

  StudentsFileDownloader({
    @required this.studentManager,
  });

  void writeStudentsToFile(BuildContext context) async {
    Directory directory = await DirectoryPicker.pick(
        context: context, rootDirectory: await getExternalStorageDirectory());
    if (directory != null) {
      final path = directory.path;
      List<Student> students = (studentManager.latestStudents);
      List<List<dynamic>> rows = students
          .map((s) => studentToData(s))
          .toList()
          .map((r) => r.values.toList())
          .toList();
      List<dynamic> topics =
          students.map((s) => studentToData(s)).toList()[0].keys.toList();
      rows.insert(0, topics);
      String csv = const ListToCsvConverter().convert(rows);
      FileIO.write(path: '$path/students.csv', data: csv);
      showSuccessDialog(context,message: "The file saved in : $path");
    }
  }
}
