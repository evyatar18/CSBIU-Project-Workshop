import 'package:flutter/material.dart';

import 'student_form.dart';

class NewStudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create New Student'),
        ),
        body: SingleChildScrollView(child: StudentForm(),) ,
        resizeToAvoidBottomPadding: false
      ),
    );
  }
}
