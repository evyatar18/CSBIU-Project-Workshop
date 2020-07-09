import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_filterable_table.dart';

import 'new_student_view.dart';
import 'student_view.dart';

import '../student.dart';

class StudentTableScreen<T extends Student, S extends Project>
    extends StatelessWidget {
  final StudentManager<T> studentManager;
  final ProjectManager<S> projectManager;
  final void Function(BuildContext, Student) onStudentClick;
  final bool showAddButton;
  final String title;

  StudentTableScreen({
    this.title = "Students",
    @required this.studentManager,
    @required this.projectManager,
    this.onStudentClick = _onStudentClick,
    this.showAddButton = true,
  });

  static void _onStudentClick(BuildContext context, Student student) {
    StudentManager sm = Provider.of<StudentManager>(context, listen: false);
    ProjectManager pm = Provider.of<ProjectManager>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetails(
          student: student,
          studentManager: sm,
          projectManager: pm,
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
          heroTag: makeHerotag(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StudentManager>.value(value: studentManager),
        Provider<ProjectManager>.value(value: projectManager),
      ],
      child: Scaffold(
        body: createFilterableStudentsTable(
          studentManager.students,
          onStudentClick,
          title,
        ),
        floatingActionButton: showAddButton ? _buildAddButton() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
