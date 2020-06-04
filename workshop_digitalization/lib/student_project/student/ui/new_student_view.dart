import 'package:flutter/material.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';
import 'package:workshop_digitalization/student_project/ui/new_element_screen.dart';

import '../student_element_manager.dart';
import 'student_form.dart';

class NewStudentScreen extends StatelessWidget {
  final StudentManager studentManager;

  NewStudentScreen({Key key, @required this.studentManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NewElementScreen<Student>(
      elementManager: StudentElementManager(studentManager),
      elementName: "student",
      elementFormCreator: StudentForm.elementForm,
    );
  }
}