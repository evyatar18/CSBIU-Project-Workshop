import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workshop_digitalization/student_project/student/local_student.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

class StudentsFileDownloader {
  final StudentManager studentManager;

  StudentsFileDownloader({
    @required this.studentManager,
  });

  void writeCounter() async {
    final directory = await getExternalStorageDirectory();
    final path = directory.path;
    // List< LocalStudent> students = (await studentManager.students.toList()).expand((x)=>x).toList();
    List<Student> students = (studentManager.latestStudents);

    List<List<dynamic >> rows = students.map((s)=>toData(s)).toList().map((r)=>r.values.toList()).toList();
    String csv = const ListToCsvConverter().convert(rows);

    final File file = await File('$path/students.csv').create();
    // Write the file.
    await file.writeAsString(csv);
    print(file.path);
  }
  static void readCounter() async {
  try {
    final directory = await getExternalStorageDirectory();
    final path = directory.path;
    final File file = File('$path/students.txt');

    // Read the file.
    String contents = await file.readAsString();

    print(contents);
  } catch (e) {
    // If encountering an error, return 0.
    print('0');
  }
}
}
