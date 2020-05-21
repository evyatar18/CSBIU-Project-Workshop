import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/global/json/jsonable_details.dart';
import 'package:workshop_digitalization/global/ui/tab_title.dart';
import 'package:workshop_digitalization/memos/ui/memos_list.dart';
import 'package:workshop_digitalization/student/firebase_student.dart';

import '../student.dart';
import 'student_form_wrapper.dart';

class StudentDetails extends StatelessWidget implements JsonableDetails {
  final Student student;
  StudentDetails({@required this.student});

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).canvasColor;

    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("${student.firstName} ${student.lastName}"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {},
                child: Icon(Icons.call, color: color),
              ),
              FlatButton(
                onPressed: () {},
                child: Icon(Icons.mail, color: color),
              )
            ],
            bottom: TabBar(
              tabs: [
                Tab(child: TabName(title: 'Details')),
                Tab(child: TabName(title: 'Memos')),
                Tab(child: TabName(title: 'Documents')),
                Tab(child: TabName(title: 'Project')),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              StudentDetailsForm(student: student),
              MemoScaffold(
                memoManager: student.memos,
              ),
              createFileContainerDisplayer(container: student.files),
              Icon(Icons.edit_attributes),
            ],
          ),
        ),
      ),
    );
  }
}

FirebaseStudent sampleStudent() {
  return FirebaseStudent()
    ..email = 'abc@gmail.com'
    ..firstName = 'abab'
    ..lastName = 'cdcd'
    ..personalID = '1111'
    ..phoneNumber = '054123141'
    ..studyYear = 2019;
}

Future<FirebaseStudent> getStudent() async {
  final coll = Document.path<FirebaseStudent>();
  final studentSnapshot =
      await Firestore.instance.collection(coll).limit(1).getDocuments();

  return FirebaseStudent(snapshot: studentSnapshot.documents[0]);
}
