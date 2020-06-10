import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workshop_digitalization/files/ui/load_screen.dart';
import 'package:workshop_digitalization/student_project/firebase_managers.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';
import 'package:workshop_digitalization/student_project/student/ui/new_student_view.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_table.dart';

Widget _loader() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

typedef Widget StudentProjectProvided(BuildContext context,
    StudentManager studentManager, ProjectManager projectManager);

Widget createStudentProjectDependent(StudentProjectProvided builder) {
  return Consumer2<StudentManager, ProjectManager>(
    builder: (context, sm, pm, _) {
      if (sm == null || pm == null) {
        return _loader();
      }
      return builder(context, sm, pm);
    },
  );
}

typedef Widget StudentProvided(BuildContext context, StudentManager manager);

Widget createStudentDependent(StudentProvided builder) {
  return Consumer<StudentManager>(
    builder: (context, value, _) {
      if (value == null) {
        return _loader();
      }
      return builder(context, value);
    },
  );
}

Widget createStudentTable(BuildContext context) {
  return createStudentProjectDependent(
    (context, sm, pm) => StudentTableScreen<Student, Project>(
      studentManager: sm,
      projectManager: pm,
    ),
  );
}

void pushStudentTableScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: createStudentTable),
  );
}

void pushNewStudentScreen(BuildContext context) {
  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => createStudentDependent(
          (context, manager) => NewStudentScreen(studentManager: manager),
        ),
      ),
    );
  }
}

void pushNewProjectScreen(BuildContext context) {
  {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Disposer(
    //       createInFuture: () async => FirebaseManagers.instance.students,
    //       builder: (context, manager) {
    //         return NewStudentScreen(
    //           studentManager: manager,
    //         );
    //       },
    //     ),
    //   ),
    // );
  }
}

void pushProjectTableScreen(BuildContext context) {
  {}
}

void pushLoadScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => createStudentDependent(
        (context, manager) => LoadScreen(studentManager: manager),
      ),
    ),
  );
}

void openCSBIUWebsite(BuildContext context) {
  var address = 'https://www.cs.biu.ac.il/';
  launch(address);
}
