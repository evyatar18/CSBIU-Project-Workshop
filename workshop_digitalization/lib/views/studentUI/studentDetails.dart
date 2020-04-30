import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/memo.dart';
import 'package:workshop_digitalization/models/student.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/detailsTab/details.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/memosTab/memosUI.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/utils/tabName.dart';

class StudentDetails extends StatelessWidget {
  Student s = new Stud();
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
              StudentForm(student: s),
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

class Stud implements Student {
  @override
  String email;

  @override
  String firstName;

  @override
  String lastName;

  @override
  String personalID;

  @override
  String phoneNumber;

  @override
  StudentStatus status;

  @override
  int studyYear;
  Stud({
    this.email = 'abc@gmail.com',
    this.firstName = 'abab',
    this.lastName = 'cdcd',
    this.personalID = '1212121',
    this.phoneNumber = '054123141',
    this.studyYear = 2020,
  });

  @override
  // TODO: implement lastUpdate
  DateTime get lastUpdate =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  // TODO: implement loadDate
  DateTime get loadDate =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
}
