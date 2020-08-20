import 'package:flutter/material.dart';
import 'package:workshop_digitalization/student_project/ui/edit_element_screen.dart';

import 'student_form.dart';
import '../student.dart';
import '../student_element_manager.dart';

class StudentDetailsForm extends StatelessWidget {
  final Student student;
  final StudentManager studentManager;

  StudentDetailsForm({
    @required this.student,
    @required this.studentManager,
    Key key,
  })  : assert(student != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditElementForm<Student>(
      element: student,
      elementManager: StudentElementManager(studentManager),
      formCreator: StudentForm.elementForm,
    );
  }
}
