


import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/student.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/detailsTab/studentForm.dart';

class NewStudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: StudentForm(),
      ),
    );
  }
  
}