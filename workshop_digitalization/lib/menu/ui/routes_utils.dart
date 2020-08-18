import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/settings/ui/settings_screen.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/project/ui/new_project_screen.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_table_screen.dart';
import 'package:workshop_digitalization/student_project/student/load/load_students.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';
import 'package:workshop_digitalization/student_project/student/ui/new_student_view.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_table.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';

Widget _loader(String title) {
  return LabeledCircularLoader(labels: [title]);
}

typedef Widget StudentProjectProvided(BuildContext context,
    StudentManager studentManager, ProjectManager projectManager);

Widget createStudentProjectDependent(StudentProjectProvided builder) {
  return Consumer2<StudentManager, ProjectManager>(
    builder: (context, sm, pm, _) {
      if (sm == null || pm == null) {
        return _loader("Acquiring student and project managers");
      }
      return builder(context, sm, pm);
    },
  );
}

typedef Widget StudentProvided(BuildContext context, StudentManager manager);
typedef Widget ProjectProvided(BuildContext context, ProjectManager manager);
typedef Widget FirebaseProvided(
    BuildContext context, FirebaseInstance instance);

Widget createStudentDependent(StudentProvided builder) {
  return Consumer<StudentManager>(
    builder: (context, value, _) {
      if (value == null) {
        return _loader("Acquiring student manager");
      }
      return builder(context, value);
    },
  );
}

Widget createProjectDependent(ProjectProvided builder) {
  return Consumer<ProjectManager>(
    builder: (context, value, _) {
      if (value == null) {
        return _loader("Acquiring project manager");
      }
      return builder(context, value);
    },
  );
}

Widget createFirebaseDependent(FirebaseProvided builder) {
  return Consumer<FirebaseInstance>(
    builder: (context, value, _) {
      if (value == null) {
        return _loader("Acquiring firebase instance");
      }
      return builder(context, value);
    },
  );
}

Widget createStudentTable({bool showAddButton = true}) {
  return createStudentProjectDependent((context, sm, pm) {
    return StudentTableScreen<Student, Project>(
      studentManager: sm,
      projectManager: pm,
      showAddButton: showAddButton,
    );
  });
}

void pushSettingsScreen(BuildContext context) {
  pushWithProviderValues(
    context,
    (_) => createSettingsScreen(),
  );
}

Widget createSettingsScreen() {
  // await Settings.init(
  //   cacheProvider: _isUsingHive ? HiveCache() : SharePreferenceCache(),
  // );
  return AppSettings();
}

void pushWithProviderValues(BuildContext context, WidgetBuilder widget) {
  final sm = Provider.of<StudentManager>(context, listen: false);
  final pm = Provider.of<ProjectManager>(context, listen: false);
  final FirebaseInstance firebase =
      Provider.of<FirebaseInstance>(context, listen: false);

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) {
      return MultiProvider(
        providers: [
          Provider.value(value: sm),
          Provider.value(value: pm),
          Provider.value(value: firebase),
        ],
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

Widget createProjectTable({bool showAddButton = true}) {
  return createStudentProjectDependent((context, sm, pm) {
    return ProjectTableScreen<Student, Project>(
      studentManager: sm,
      projectManager: pm,
      showAddButton: showAddButton,
    );
  });
}

void pushNewProjectScreen(BuildContext context) {
  {
    pushWithProviderValues(
      context,
      (_) => createProjectDependent(
        (context, manager) => createFirebaseDependent(
          (context, instance) => NewProjectScreen(
            projectManager: manager,
            firebase: instance,
          ),
        ),
      ),
    );
  }
}

void pushProjectTableScreen(BuildContext context) {
  pushWithProviderValues(context, (context) => createProjectTable());
}

void pushLoadScreen(BuildContext context) {
  pushWithProviderValues(
    context,
    (_) => createStudentDependent(
      (context, manager) => StudentLoaderScreen(manager),
    ),
  );
}

void openCSBIUWebsite(BuildContext context) {
  var address = 'https://www.cs.biu.ac.il/';
  launch(address);
}
