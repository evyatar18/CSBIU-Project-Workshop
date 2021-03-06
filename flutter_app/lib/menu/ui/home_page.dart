import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

import 'routes_utils.dart';
import 'bottom_fab.dart';
import 'main_menu.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

typedef Widget EmptyWidgetBuilder();

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex;

  final _children = <EmptyWidgetBuilder>[
    // array of functions that create the main screens of the app
    () => MainMenu(),
    () => createStudentTable(showAddButton: false),
    () => createProjectTable(showAddButton: false),
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
  Widget build(BuildContext context) => _body(context);
}
