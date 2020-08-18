import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workshop_digitalization/firebase_roots/dynamic_root/setup.dart';
import 'package:workshop_digitalization/settings/ui/settings_screen.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/project/ui/new_project_screen.dart';
import 'package:workshop_digitalization/student_project/project/ui/project_table_screen.dart';
import 'package:workshop_digitalization/student_project/student/load/load_students.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';
import 'package:workshop_digitalization/student_project/student/ui/new_student_view.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_table.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';

/// utility method for creating the LabeledCircularLoader with the given title
Widget _loader(String title) {
  return LabeledCircularLoader(labels: [title]);
}

/// a widget which needs to be provided both with a `StudentManager` and a `ProjectManager`
typedef Widget _StudentProjectProvided(BuildContext context,
    StudentManager studentManager, ProjectManager projectManager);

/// create a widget which receives instances of `StudentManager` and `ProjectManager`
Widget createStudentProjectDependent(_StudentProjectProvided builder) {
  return Consumer2<StudentManager, ProjectManager>(
    builder: (context, sm, pm, _) {
      if (sm == null || pm == null) {
        return _loader("Acquiring student and project managers");
      }
      return builder(context, sm, pm);
    },
  );
}

/// an object which needs a `StudentManager` instance
typedef Widget _StudentProvided(BuildContext context, StudentManager manager);

/// an object which needs a `ProjectManager` instance
typedef Widget _ProjectProvided(BuildContext context, ProjectManager manager);

/// an object which needs a `FirebaseInstance` instance
typedef Widget _FirebaseProvided(
    BuildContext context, FirebaseInstance instance);

/// create a widget which receives an instance of `StudentManager`
Widget createStudentDependent(_StudentProvided builder) {
  return Consumer<StudentManager>(
    builder: (context, value, _) {
      if (value == null) {
        return _loader("Acquiring student manager");
      }
      return builder(context, value);
    },
  );
}

/// create a widget which receives an instance of `ProjectManager`
Widget createProjectDependent(_ProjectProvided builder) {
  return Consumer<ProjectManager>(
    builder: (context, value, _) {
      if (value == null) {
        return _loader("Acquiring project manager");
      }
      return builder(context, value);
    },
  );
}

/// create a widget which receives an instance of `FirebaseInstance`
Widget createFirebaseDependent(_FirebaseProvided builder) {
  return Consumer<FirebaseInstance>(
    builder: (context, value, _) {
      if (value == null) {
        return _loader("Acquiring firebase instance");
      }
      return builder(context, value);
    },
  );
}

/// create the students table
Widget createStudentTable({bool showAddButton = true}) {
  return createStudentProjectDependent((context, sm, pm) {
    return StudentTableScreen<Student, Project>(
      studentManager: sm,
      projectManager: pm,
      showAddButton: showAddButton,
    );
  });
}

/// create the projects table
Widget createProjectTable({bool showAddButton = true}) {
  return createStudentProjectDependent((context, sm, pm) {
    return ProjectTableScreen<Student, Project>(
      studentManager: sm,
      projectManager: pm,
      showAddButton: showAddButton,
    );
  });
}

/// pushes a widget to the navigator with the `StudentManager`, `ProjectManager` and `FirebaseInstance` providers for it to use
void _pushWithProviderValues(BuildContext context, WidgetBuilder widget) {
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

void pushSettingsScreen(BuildContext context) {
  _pushWithProviderValues(
    context,
    (_) => createSettingsScreen(),
  );
}

Widget createSettingsScreen() {
  return AppSettings();
}

void pushStudentTableScreen(BuildContext context) {
  _pushWithProviderValues(context, (context) => createStudentTable());
}

void pushNewStudentScreen(BuildContext context) {
  _pushWithProviderValues(
    context,
    (_) => createStudentDependent(
        (context, manager) => NewStudentScreen(studentManager: manager)),
  );
}

void pushNewProjectScreen(BuildContext context) {
  _pushWithProviderValues(
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

void pushProjectTableScreen(BuildContext context) {
  _pushWithProviderValues(context, (context) => createProjectTable());
}

void pushStudentLoadScreen(BuildContext context) {
  _pushWithProviderValues(
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
