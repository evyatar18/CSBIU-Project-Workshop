import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/menu/ui/bottom_fab.dart';
import 'package:workshop_digitalization/menu/ui/main_menu.dart';
import 'package:workshop_digitalization/student_project/firebase_managers.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import 'routes_utils.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

typedef Widget EmptyWidgetBuilder();

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex;

  List<EmptyWidgetBuilder> _children = [
    () => MainMenu(),
    () => createStudentTable(),
    () => createProjectTable(),
    () => createSettingsScreen(),
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

  Widget _body(BuildContext context) {
    return Scaffold(
      floatingActionButton: BottomFab(
        _currentIndex,
      ),
      body: _children[_currentIndex](),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        hasNotch: false,
        fabLocation: BubbleBottomBarFabLocation.end,
        opacity: .2,
        currentIndex: _currentIndex,
        onTap: changePage,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ), //border radius doesn't work when the notch is enabled.
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
            title: Text("Settings"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider<StudentManager>(
          create: (_) => FirebaseManagers.instance.students,
          lazy: false,
        ),
        FutureProvider<ProjectManager>(
          create: (_) => FirebaseManagers.instance.projects,
          lazy: false,
        ),
      ],
      child: _body(context),
    );
  }
}
