import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/auth/auth.dart';
import 'package:workshop_digitalization/auth/ui/auth_wrapper.dart';
import 'package:workshop_digitalization/auth/ui/authorization_checker.dart';
import 'package:workshop_digitalization/auth/ui/sign_out.dart';
import 'package:workshop_digitalization/csv/ui/load_screen.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/ui/db_data.dart';
import 'package:workshop_digitalization/firebase_consts/firebase_root.dart';
import 'package:workshop_digitalization/firebase_consts/lib.dart' as globs;
import 'package:workshop_digitalization/student_project/project/firebase_project.dart';
import 'package:workshop_digitalization/menu/ui/home_page.dart';
import 'package:workshop_digitalization/student_project/student/firebase_student.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_view.dart';

import 'settings/settings.dart';
import 'student_project/firebase_managers.dart';
import 'student_project/project/project.dart';
import 'student_project/student/dummy_student.dart';
import 'student_project/student/student.dart';

import 'files/firebase.dart';
import 'files/ui/file_view.dart';
import 'global/ui/disposer.dart';
import 'memos/memo.dart';
import 'progress/progress.dart';
import 'progress/progress_repo.dart';
import 'progress/ui/multiple_progress_bars.dart';
import 'progress/ui/progress_bar.dart';
import 'progress/ui/progress_displayer.dart';
import 'student_project/student/ui/student_table.dart';
import 'global/ui/circular_loader.dart';
import 'global/ui/completely_centered.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // use default shared preferences provider
  await Settings.init();
  globs.initRoots();

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Digitalization',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: DynamicDBHandler(
          builder: (context) {
            return Authorizer(
              builder: (context, user) {
                // now the current user is authorized, we can show the root updater
                return _buildRootUpdater(_mainBodyBuilder);
              },
            );
          },
        ),
      ),
    );
  }

  /// Builds the students and projects providers
  /// Then builds the actual application
  Widget _mainBodyBuilder(BuildContext context) {
    final firebase = Provider.of<FirebaseInstance>(context);
    final students = firebase.root.studentManager;
    final projects = firebase.root.projectManager;

    return MultiProvider(
      providers: [
        Provider.value(value: students),
        Provider.value(value: projects),
      ],
      child: MyHomePage(),
    );
  }

  /// The widget which updates the view each time the root is changed
  Widget _buildRootUpdater(WidgetBuilder childBuilder) {
    // we use FutureBuilder to get a **default** root collection
    return FutureBuilder<String>(
      future: MyAppSettings.defaultRoot,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CompletelyCentered(
            children: [
              Text("Failed loading default root:"),
              Text(snapshot.error.toString()),
            ],
          );
        }

        if (!snapshot.hasData) {
          return LabeledCircularLoader(
            labels: ["Loading default root"],
          );
        }

        final firebase = Provider.of<FirebaseInstance>(context);

        // we use a ValueChangeObserver to change the root when it is changed in the settings
        return ValueChangeObserver(
          cacheKey: MyAppSettings.firebaseRootName,
          defaultValue: snapshot.data,
          builder: (context, versionName, _) {
            // after changed a root in the settings, get the corresponding FirebaseRoot object
            // and use it as the current firebase root
            return FutureBuilder<void>(
              future:
                  firebase.roots.getRoot(versionName).then(firebase.useRoot),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return CompletelyCentered(children: [
                    Text(
                      "Failed getting and using the firebase root $versionName",
                    ),
                    Text(snapshot.error.toString()),
                  ]);
                }

                if (!snapshot.hasData) {
                  return LabeledCircularLoader(
                    labels: ["Getting root `$versionName` from firebase..."],
                  );
                }

                return Builder(builder: childBuilder);
              },
            );
          },
        );
      },
    );
  }
}

void saveMemo() async {
  final stud = FirebaseStudent();
  DocumentAccessor a = DocumentAccessor();
  a.save(stud);

  Memo m = await stud.memos.createEmpty();
  m.content = "hello world";
  await stud.memos.save(m);
}

Stream<List<Student>> getStudents() async* {
  final items = new List<Student>.generate(20, (i) {
    return new DummyStudent();
  });
  while (true) {
    await Future.delayed(Duration(seconds: 5));

    // print(items.map((e) => "title: ${e.title}, year: ${e.year}").join(", "));

    yield items;
  }
}

Widget loadScreen() => LoadScreen(studentManager: FirebaseStudentManager());

Widget firebaseStudentsTable() {
  return Disposer(
    createInFuture: () async => FirebaseManagers.instance.students,
    builder: (context, manager) {
      return Disposer(
        createInFuture: () async {
          final projects = await FirebaseManagers.instance.projects;
          // final proj = await projects.createEmpty();
          // proj.projectGoal = "example goal";
          // proj.mentor =
          //     FirebasePerson(firstName: "israel", lastName: "israeli");
          // proj.projectSubject = "subject #2";

          // await projects.save(proj);

          return projects;
        },
        builder: (context, projectManager) {
          return StudentTableScreen<FirebaseStudent, FirebaseProject>(
            studentManager: manager,
            projectManager: projectManager,
          );
        },
      );
    },
  );
}

Widget fileContainer() {
  return Disposer(
    create: () => FBFileContainer(Firestore.instance.collection("files")),
    builder: (context, container) {
      return Disposer(
        create: () => ProgressRepository(),
        builder: (context, repo) {
          return FileContainerDisplayer(container: container, repo: repo);
        },
      );
    },
  );
}

Widget progressIndicators() {
  var progress = ProgressSnapshot("task1", "in progress...", 0.74);
  var success = ProgressSnapshot("task2", "done", 1);
  var error = ProgressSnapshot("task3", "ERROR", 0.41, failed: true);

  return Column(
    children: <Widget>[
      LinearProgressBar(snapshot: progress),
      LinearProgressBar(snapshot: success),
      LinearProgressBar(snapshot: error)
    ],
  );
}

Widget progressPopup() {
  return Builder(builder: (context) {
    var items = List.generate(
        10, (i) => createDummyProgressStream("task $i").asBroadcastStream());
    // items.forEach((st) => st.listen((snap) => print(
    //     "${snap.taskName}, ${snap.progress}, failed:${snap.failed}, ${snap.message}")));

    return FlatButton(
        onPressed: () => showUpdatingSnapshotsDialog(context, items),
        child: Text("PRESS ME!"));
  });
}

Widget progressScaffold() {
  final repo = ProgressRepository();
  var items = List.generate(
      10, (i) => createDummyProgressStream("task $i").asBroadcastStream());

  items.forEach((stream) async {
    int id = await repo.createId(await stream.first);

    stream.listen((update) {
      repo.pushUpdate(id, update);
    });
  });

  return ProgressScaffold(repo: repo, body: Text("current active progresses"));
}

Widget student() {
  final stud = FirebaseStudent(id: "hwDaXlndqUWVjIzQ0Lfp");
  DocumentAccessor a = DocumentAccessor();
  a.save(stud);

  // stud.memos.createEmpty();

  return StudentDetails(student: stud);
}

// class MyApps extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// class _MyAppState extends State<MyApps> {
//   String _openResult = 'Unknown';

//   Future<void> openFile() async {
//     final filePath = '/storage/emulated/0/update.apk';
//     final result = await OpenFile.open(filePath);

//     setState(() {
//       _openResult = "type=${result.type}  message=${result.message}";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       home: new Scaffold(
//         appBar: new AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text('open result: $_openResult\n'),
//               FlatButton(
//                 child: Text('Tap to open file'),
//                 onPressed: openFile,
//               ),
//               Container(
//                 child:
//                     createFieldFilter("field1", <String>["filter1", "filter2"]),
//                 margin: EdgeInsets.all(20),
//               ),
//               createFieldFilter(
//                   "field2", <String>["filter1", "filter2", "field3"]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// void testModel() async {
//   File f = File("${Directory.systemTemp.path}/test.txt");
//   // if (!Directory.systemTemp.exists()) {
//   //   Directory.systemTemp.createSync({})
//   // }
//   f.createSync(recursive: true);
//   f.writeAsStringSync("hello world");

//   DocumentAccessor accessor = DocumentAccessor();
//   var test = TestFileDocument();
//   await accessor.save(test);

//   FileContainer container = test.fc;

//   await test.fc.addFile(f).last;
//   await accessor.update(test);

//   for (FBFileInfo fi in container.getFiles()) {
//     print(fi.fileName);
//   }

//   await container.removeFile(container.getFiles()[0]);

//   for (FBFileInfo fi in container.getFiles()) {
//     print(fi.fileName);
//   }

//   await accessor.delete(test);

//   print("done");
// }
