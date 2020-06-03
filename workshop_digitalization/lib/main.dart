import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/files/ui/load_screen.dart';
import 'package:workshop_digitalization/student_project/student/firebase_student.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_view.dart';

import 'student_project/firebase_managers.dart';
import 'student_project/student/dummy_student.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final firestore = Firestore.instance;
  final root = firestore.collection('version').document('1');
  Flamingo.configure(
      firestore: firestore, storage: FirebaseStorage.instance, root: root);

  // saveMemo();

  runApp(new MyApp());
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Digitalization',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(body: firebaseStudentsTable()),
    );
  }
}

Widget loadScreen() => LoadScreen(studentManager: FirebaseStudentManager());

Widget firebaseStudentsTable() {
  return Disposer(
    createInFuture: () async => FirebaseManagers.instance.students,
    builder: (context, manager) {
      return StudentTableScreen<FirebaseStudent>(
        studentManager: manager,
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
