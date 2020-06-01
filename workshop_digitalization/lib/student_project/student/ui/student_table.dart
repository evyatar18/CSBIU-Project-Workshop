import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_filterable_table.dart';

import 'new_student_view.dart';
import 'student_view.dart';

import '../student.dart';

class StudentTableScreen<T extends Student> extends StatelessWidget {
  final StudentManager<T> studentManager;
  final void Function(BuildContext, Student) onStudentClick;
  final bool showAddButton;

  StudentTableScreen({
    @required this.studentManager,
    this.onStudentClick = _onStudentClick,
    this.showAddButton = true,
  });

  static void _onStudentClick(BuildContext context, Student student) {
    StudentManager sm = Provider.of<StudentManager>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetails(
          student: student,
          studentManager: sm,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Builder(
      builder: (context) {
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewStudentScreen(studentManager: studentManager),
              ),
            );
          },
          heroTag: randomString(10),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider<StudentManager>.value(
      value: studentManager,
      child: Scaffold(
        body: createFilterableStudentsTable(studentManager.students, onStudentClick),
        floatingActionButton: showAddButton ? _buildAddButton() : null,
      ),
    );
  }
}