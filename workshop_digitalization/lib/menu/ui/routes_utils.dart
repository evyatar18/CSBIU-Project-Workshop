import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workshop_digitalization/csv/ui/load_screen.dart';
import 'package:workshop_digitalization/settings/ui/settings_screen.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_table_screen.dart';
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

Widget createStudentTable() {
  return createStudentProjectDependent((context, sm, pm) {
    return StudentTableScreen<Student, Project>(
      studentManager: sm,
      projectManager: pm,
    );
  });
}

void pushSettingsScreen(BuildContext context) {
  pushWithProviderValues(
    context,
    (_) => createSettingsScreen(),
  );
}

Widget createSettingsScreen(){
  // await Settings.init(
  //   cacheProvider: _isUsingHive ? HiveCache() : SharePreferenceCache(),
  // );
  return SettingsScreen();
}

void pushWithProviderValues(BuildContext context, WidgetBuilder widget) {
  final sm = Provider.of<StudentManager>(context, listen: false);
  final pm = Provider.of<ProjectManager>(context, listen: false);

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) {
      return MultiProvider(
        providers: [Provider.value(value: sm), Provider.value(value: pm)],
        child: Builder(builder: (context) => widget(context)),
      );
    }),
  );
}

void pushStudentTableScreen(BuildContext context) {
  pushWithProviderValues(context, (context) => createStudentTable());
}

void pushNewStudentScreen(BuildContext context) {
  pushWithProviderValues(
    context,
    (_) => createStudentDependent(
        (context, manager) => NewStudentScreen(studentManager: manager)),
  );
}

Widget createProjectTable() {
  return createStudentProjectDependent((context, sm, pm) {
    return ProjectTableScreen<Student, Project>(
      studentManager: sm,
      projectManager: pm,
    );
  });
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
  pushWithProviderValues(context, (context) => createProjectTable());
}

void pushLoadScreen(BuildContext context) {
  pushWithProviderValues(
    context,
    (_) => createStudentDependent(
        (context, manager) => LoadScreen(studentManager: manager)),
  );
}

void openCSBIUWebsite(BuildContext context) {
  var address = 'https://www.cs.biu.ac.il/';
  launch(address);
}
