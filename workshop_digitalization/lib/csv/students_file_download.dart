
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/path_suplier.dart';
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
    final path = await getDownloadPath(context);
    if (path == null) {
      return;
    }
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
    showSuccessDialog(context, message: "The file saved in : $path");
  }
}
