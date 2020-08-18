import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:workshop_digitalization/menu/ui/routes_utils.dart';

class BottomFab extends StatefulWidget {
  final int index;
  BottomFab(int index) : index = index;

  @override
  State<StatefulWidget> createState() => _BottomFabState();
}

class _BottomFabState extends State<BottomFab> {
  List<List<SpeedDialChild>> _children(BuildContext context) {
    return [
      [],
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
      ],
      [
        SpeedDialChild(
          child: Icon(Icons.note_add),
          backgroundColor: Colors.green,
          label: 'Add Project',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => pushNewProjectScreen(context),
        )
      ],
      []
    ];
  }

  @override
  Widget build(BuildContext context) {
    final children = _children(context)[widget.index];
    return SpeedDial(
      // both default to 16
      marginRight: 18,
      marginBottom: 20,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // this is ignored if animatedIcon is non null
      visible: children.isNotEmpty,
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
      children: children,
    );
  }
}
