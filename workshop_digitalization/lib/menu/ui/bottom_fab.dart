import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:workshop_digitalization/menu/ui/routes_utils.dart';

class BottomFab extends StatefulWidget {
  int index;
  BottomFab(int index) {
    this.index = index;
  }

  @override
  State<StatefulWidget> createState() {
    return BottomFabState();
  }
}

class BottomFabState extends State<BottomFab> {

  List<List<SpeedDialChild>> _children(BuildContext context) {
    return [
      [
        SpeedDialChild(
            child: Icon(Icons.settings),
            backgroundColor: Colors.green,
            label: 'Settings',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('FIRST CHILD')),
        SpeedDialChild(
            child: Icon(Icons.person),
            backgroundColor: Colors.blue,
            label: 'Profile',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('FIRST CHILD')),
      ],
      [
        SpeedDialChild(
            child: Icon(Icons.person_add),
            backgroundColor: Colors.green,
            label: 'Add Student',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => pushNewStudentScreen(context)),
        SpeedDialChild(
          child: Icon(Icons.file_upload),
          backgroundColor: Colors.blue,
          label: 'Upload Students CSV',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => pushLoadScreen(context),
        ),
        SpeedDialChild(
          child: Icon(Icons.file_download),
          backgroundColor: Colors.yellow,
          label: 'Download Students CSV',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('THIRD CHILD'),
        ),
      ],
      [
        SpeedDialChild(
          child: Icon(Icons.note_add),
          backgroundColor: Colors.green,
          label: 'Add Project',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('THIRD CHILD'),
        ),
        SpeedDialChild(
          child: Icon(Icons.file_download),
          backgroundColor: Colors.blue,
          label: 'Download Projects CSV',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('THIRD CHILD'),
        ),
      ],
      [
        SpeedDialChild(
            child: Icon(Icons.person),
            backgroundColor: Colors.green,
            label: 'Profile',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('FIRST CHILD')),
      ]
    ];
  }

 

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        //\ child: Icon(Icons.add),
        visible: true,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: (_children(context)[widget.index]));
  }
}
