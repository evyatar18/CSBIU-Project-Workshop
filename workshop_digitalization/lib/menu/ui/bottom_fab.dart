import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/csv/projects_file_download.dart';
import 'package:workshop_digitalization/csv/students_file_download.dart';
import 'package:workshop_digitalization/menu/ui/routes_utils.dart';
import 'package:workshop_digitalization/student_project/project/project.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

class BottomFab extends StatefulWidget {
  final int index;
  BottomFab(int index) : index = index;

  @override
  State<StatefulWidget> createState() {
    return BottomFabState();
  }
}

class BottomFabState extends State<BottomFab> {
  List<List<SpeedDialChild>> _children(BuildContext context) {
    StudentsFileDownloader studentsFileDownloader = new StudentsFileDownloader(
      studentManager: Provider.of<StudentManager>(context, listen: false),
    );
    ProjectsFileDownloader projectsFileDownloader = new ProjectsFileDownloader(
      projectManager: Provider.of<ProjectManager>(context, listen: false),
    );
    return [
      [
        SpeedDialChild(
            child: Icon(Icons.settings),
            backgroundColor: Colors.green,
            label: 'Settings',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('settings')),
        SpeedDialChild(
            child: Icon(Icons.person),
            backgroundColor: Colors.blue,
            label: 'Profile',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('profile')),
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
          onTap: () => studentsFileDownloader.writeStudentsToFile(context),
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
          onTap: () => projectsFileDownloader.writeProjectsToFile(context),
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
