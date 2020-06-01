import 'package:flutter/material.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import 'student_form.dart';

class NewStudentScreen extends StatelessWidget {
  final StudentManager studentManager;

  const NewStudentScreen({Key key, @required this.studentManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create New Student'),
        ),
        body: SingleChildScrollView(
          child: StudentForm(),
        ),
        resizeToAvoidBottomPadding: false,
      ),
    );
  }
}
