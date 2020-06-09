import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:workshop_digitalization/global/ui/disposer.dart';
import 'package:workshop_digitalization/menu/ui/main_menu.dart';
import 'package:workshop_digitalization/student_project/firebase_managers.dart';
import 'package:workshop_digitalization/student_project/student/firebase_student.dart';
import 'package:workshop_digitalization/student_project/student/ui/student_table.dart';

import '../../main.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex;
  List<Widget> _children = [
    MainMenu(),
    Disposer(
      createInFuture: () async => FirebaseManagers.instance.students,
      builder: (context, manager) {
        return firebaseStudentsTable();
      },
    ),
    Scaffold(),
    Scaffold()
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        hasNotch: true,
        //fabLocation: BubbleBottomBarFabLocation.end,
        opacity: .2,
        currentIndex: _currentIndex,
        onTap: changePage,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                16)), //border radius doesn't work when the notch is enabled.
        elevation: 8,
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
              backgroundColor: Colors.red,
              icon: Icon(
                Icons.home,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.home,
                color: Colors.red,
              ),
              title: Text("Home")),
          BubbleBottomBarItem(
              backgroundColor: Colors.deepPurple,
              icon: Icon(
                Icons.table_chart,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.table_chart,
                color: Colors.deepPurple,
              ),
              title: Text("Students")),
          BubbleBottomBarItem(
              backgroundColor: Colors.green,
              icon: Icon(
                Icons.dashboard,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: Colors.green,
              ),
              title: Text("Projects")),
          BubbleBottomBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.settings,
                color: Colors.indigo,
              ),
              title: Text("Settings")),
        ],
      ),
    );
  }
}
