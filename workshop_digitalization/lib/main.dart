import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/views/disposer.dart';

import 'models/files/firebase.dart';
import 'models/views/file_container.dart';
import 'package:workshop_digitalization/views/studentUI/studentDetails.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final firestore = Firestore.instance;
  final root = firestore.collection('version').document('1');
  Flamingo.configure(
      firestore: firestore, storage: FirebaseStorage.instance, root: root);

  // testModel();

  // runApp(new MyApp());
  runApp(new StudentDetails());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Digitalization',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hello world"),
        ),
        body: Disposer(
          create: () => FBFileContainer(Firestore.instance.collection("files")),
          builder: (context, container) {
            return FileContainerDisplayer(container: container);
          },
        ),
      ),
    );
  }

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
