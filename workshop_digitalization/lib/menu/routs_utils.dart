import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workshop_digitalization/files/ui/load_screen.dart';
import 'package:workshop_digitalization/global/ui/disposer.dart';
import 'package:workshop_digitalization/student_project/firebase_managers.dart';
import 'package:workshop_digitalization/student_project/student/firebase_student.dart';
import 'package:workshop_digitalization/student_project/student/ui/new_student_view.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_table.dart';

import '../main.dart';

void pushStudentTableScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => Disposer(
              createInFuture: () async => FirebaseManagers.instance.students,
              builder: (context, manager) {
                return firebaseStudentsTable();
              },
            )),
  );
}

void pushNewStudentScreen(BuildContext context) {
  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Disposer(
          createInFuture: () async => FirebaseManagers.instance.students,
          builder: (context, manager) {
            return NewStudentScreen(
              studentManager: manager,
            );
          },
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
      builder: (context) => Disposer(
        createInFuture: () async => FirebaseManagers.instance.students,
        builder: (context, manager) {
          return LoadScreen(
            studentManager: manager,
          );
        },
      ),
    ),
  );
}

void openCSBIUWebsite(BuildContext context) {
  var address = 'https://www.cs.biu.ac.il/';
  launch(address);
}
