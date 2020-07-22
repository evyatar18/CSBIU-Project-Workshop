import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'routes_utils.dart';

class BigIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  BigIcon({this.text, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: (context, constraint) {
        return new Column(
          children: <Widget>[
            Container(
              child: SizedBox(
                width: constraint.biggest.height * 0.6,
                height: constraint.biggest.height * 0.6,
                child: new Icon(
                  icon,
                  size: constraint.biggest.height * 0.5,
                  color: this.color,
                ),
              ),
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: this.color,
                  width: 5.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text("CS-BIU Workshop"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: GridView.count(
          crossAxisCount: 3,
          children: <Widget>[
            FlatButton(
              child: BigIcon(
                icon: Icons.table_chart,
                text: 'Students',
                color: Colors.blue,
              ),
              onPressed: () => pushStudentTableScreen(context),
            ),
            FlatButton(
              child: BigIcon(
                icon: Icons.person_add,
                text: 'Add Student',
                color: Colors.green,
              ),
              onPressed: () => pushNewStudentScreen(context),
            ),
            FlatButton(
              child: BigIcon(
                icon: Icons.dashboard,
                text: 'Projects',
                color: Colors.red,
              ),
              onPressed: () => pushProjectTableScreen(context),
            ),
            FlatButton(
              child: BigIcon(
                icon: Icons.note_add,
                text: 'New Project',
                color: Colors.yellow,
              ),
              onPressed: () => pushNewProjectScreen(context),
            ),
            FlatButton(
              child: BigIcon(
                icon: Icons.file_upload,
                text: 'Load Students',
                color: Colors.cyan,
              ),
              onPressed: () => pushLoadScreen(context),
            ),
            FlatButton(
              child: BigIcon(
                icon: Icons.language,
                text: 'cs.biu.ac.il',
                color: Colors.blueGrey,
              ),
              onPressed: () => openCSBIUWebsite(context),
            ),
          ],
        ),
      ),
    );
  }
}
