import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:workshop_digitalization/firebase_consts/firebase_root.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/settings/settings.dart';

import 'package:workshop_digitalization/firebase_consts/lib.dart' as globs;

class AppSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SettingsScreen(
        title: "Application Settings",
        children: [
          SettingsGroup(
            title: "Database Roots",
            children: _buildRoots(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoots(BuildContext context) {
    return <Widget>[
      StreamBuilder<List<FirebaseRoot>>(
        stream: globs.roots.rootStream,
        initialData: globs.roots.roots,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading database roots...");
          }

          final roots = snapshot.data;
          final rootNames = roots.map((e) => e.name).toList();
          final defaultRoot = rootNames.isEmpty ? null : rootNames.first;

          return DropDownSettingsTile<String>(
            title: "Database Root",
            settingKey: MyAppSettings.firebaseRootName,
            values: Map.fromEntries(
              roots
                  .map((root) => root.name)
                  .map((name) => MapEntry(name, capitalize(name))),
            ),
            selected:
                globs.currentRoot != null && roots.contains(globs.currentRoot)
                    ? globs.currentRoot.name
                    : defaultRoot,
            onChange: MyAppSettings.setRoot,
          );
        },
      ),
      RaisedButton(
        child: Text("Add Root"),
        onPressed: () async {
          final name = await showTextInputDialog(context, "Route Name");
          if (name != null) {
            if (name.isEmpty) {
              showAlertDialog(context, "Given root name is empty",
                  "Root name cannot be empty");
            } else {
              // create the root if it does not exist
              globs.roots.getRoot(name);
            }
          }
        },
      ),
    ];
  }
}
