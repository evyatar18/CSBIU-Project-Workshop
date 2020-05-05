import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/memo.dart';
import 'package:workshop_digitalization/models/student/firebase_student.dart';
import 'package:workshop_digitalization/models/student/student.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/detailsTab/details.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/memosTab/memosUI.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/utils/tabName.dart';
import 'package:workshop_digitalization/views/table/jsonableDetails.dart';

class StudentDetails extends StatelessWidget implements JsonableDetails{
  Student s ;
  StudentDetails(this.s);

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).canvasColor;

    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("${s.firstName} ${s.lastName}"),
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
                Tab(child: TabName('Details')),
                Tab(child: TabName('Memo\'s')),
                Tab(child: TabName('Documents')),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              StudentDetailsForm(student: s),
              MemoList(memos: new List<Memo>.generate(100, (i) => new Mem())),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}



class Mem implements Memo {
  @override
  String content = 'sdfsf';

  @override
  String topic = 'MEMO';

  @override
  // TODO: implement creationDate
  DateTime get creationDate =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  // TODO: implement lastUpdate
  DateTime get lastUpdate => null;
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
  final studentSnapshot = await Firestore.instance.collection(coll).limit(1).getDocuments();

  return FirebaseStudent(snapshot: studentSnapshot.documents[0]);
}

// class Stud implements Student {
//   @override
//   String email;

//   @override
//   String firstName;

//   @override
//   String lastName;

//   @override
//   String personalID;

//   @override
//   String phoneNumber;

//   @override
//   StudentStatus status;

//   @override
//   int studyYear;
//   static int allID= 1;
//   Stud({
//     this.email = 'abc@gmail.com',
//     this.firstName = 'abab',
//     this.lastName = 'cdcd',
//     this.personalID = '',
//     this.phoneNumber = '054123141',
//     this.studyYear = 2019,
//   }){this.personalID = allID.toString();
//   allID++;}

//   @override
//   // TODO: implement lastUpdate
//   DateTime get lastUpdate =>
//       DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

//   @override
//   // TODO: implement loadDate
//   DateTime get loadDate =>
//       DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
//    Map<String, dynamic> toData() {
//     final data = Map<String, dynamic>();

//     data[ "id"] =  personalID;
//     data[ "firstName"]= firstName;
//    data[ "lastName"]= lastName;
//     data[ "phone"] = phoneNumber;
//     data[ "email"] = email;
//     data[ "year"]= studyYear;
//     //data[ "status"] = status.index;

//     return data;
//   }


//   @override
//   Map<String, dynamic> toJson() {
//     return toData();
//   }

//   @override
//   // TODO: implement files
//   FileContainer get files => null;
// }
