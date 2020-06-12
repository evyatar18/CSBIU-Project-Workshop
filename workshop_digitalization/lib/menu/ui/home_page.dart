import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/menu/ui/main_menu.dart';
import 'package:workshop_digitalization/student_project/firebase_managers.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import 'routes_utils.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex;
  bool _dialVisible = true;

  List<WidgetBuilder> _children = [
    (_) => MainMenu(),
    createStudentTable,
    (_) => Scaffold(),
    (_) => Scaffold(),
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
      floatingActionButton: SpeedDial(
          
          // both default to 16
          marginRight: 18,
          
          marginBottom: 20,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          // this is ignored if animatedIcon is non null
          //\ child: Icon(Icons.add),
          visible: _dialVisible,
          // If true user is forced to close dial manually 
          // by tapping main button and overlay is not rendered.
          closeManually: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          onOpen: () => print('OPENING DIAL'),
          onClose: () => print('DIAL CLOSED'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.accessibility),
              backgroundColor: Colors.red,
              label: 'First',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => print('FIRST CHILD')
            ),
            SpeedDialChild(
              child: Icon(Icons.brush),
              backgroundColor: Colors.blue,
              label: 'Second',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => print('SECOND CHILD'),
            ),
            SpeedDialChild(
              child: Icon(Icons.keyboard_voice),
              backgroundColor: Colors.green,
              label: 'Third',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => print('THIRD CHILD'),
            ),
          ],
        ),
      
      body: _children[_currentIndex](context),
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
          lazy: true,
        ),
        FutureProvider<ProjectManager>(
          create: (_) => FirebaseManagers.instance.projects,
          lazy: true,
        ),
      ],
      child: Builder(builder: (context) => _body(context)),
    );
  }
}
