import 'package:flutter/material.dart';
import 'package:workshop_digitalization/student_project/element_manager.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';
import 'package:workshop_digitalization/student_project/ui/new_element_screen.dart';

import 'student_form.dart';

class StudentElementManager implements ElementManager<Student> {
  final StudentManager studentManager;

  StudentElementManager(this.studentManager);

  Future<Student> createEmpty() => studentManager.createEmpty();

  Future<void> delete(Student elem) => studentManager.delete(elem);
  Future<void> save(Student elem) => studentManager.save(elem);

  Student getById(String id) => studentManager.getStudent(id);
}

class NewStudentScreen extends StatelessWidget {
  final StudentManager studentManager;

  NewStudentScreen({Key key, @required this.studentManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NewElementScreen<Student>(
      elementManager: StudentElementManager(studentManager),
      elementName: "student",
      elementFormCreator: ({element, formBuilderKey, readOnly}) {
        return StudentForm(
          student: element,
          formBuilderKey: formBuilderKey,
          readOnly: readOnly,
        );
      },
    );
  }
}