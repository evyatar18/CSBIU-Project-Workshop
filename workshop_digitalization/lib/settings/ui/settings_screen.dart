import 'package:directory_picker/directory_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/auth/auth.dart';
import 'package:workshop_digitalization/auth/ui/sign_out.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/firebase_consts/firebase_root.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/settings/settings.dart';

class AppSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final children = _buildSettingsGroups(context);

    final auth = Provider.of<Authenticator>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Application Settings"),
        actions: <Widget>[
          SignOutButton(
            authenticator: auth,
          ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  List<Widget> _buildSettingsGroups(BuildContext context) {
    return [
      SettingsGroup(
        title: "Database Roots",
        children: _buildRoots(context),
      ),
      SettingsGroup(
        title: "Default Paths",
        children: _buildDefaultPaths(context),
      ),
    ];
  }

  List<Widget> _buildDefaultPaths(BuildContext context) {
    return <Widget>[
      SwitchSettingsTile(
        settingKey: MyAppSettings.defaultDownloadPathEnabeld,
        title: 'Default Path',
        childrenIfEnabled: <Widget>[
          ListTile(
            title: Text('Default Download Path'),
            subtitle: FutureBuilder(
                future: MyAppSettings.defaultDownloadPath,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data);
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
            onTap: () async {
              final dir = await DirectoryPicker.pick(
                message: "Default download directory",
                context: context,
                rootDirectory: await getExternalStorageDirectory(),
              );

              // user tapped outside of the dialog window
              if (dir == null) {
                showAlertDialog(context, "No directory was chosen");
                return;
              }

              MyAppSettings.setdefaultDownloadPath(dir.path);
            },
          )
        ],
      )
    ];
  }

  List<Widget> _buildRoots(BuildContext context) {
    final firebase = Provider.of<FirebaseInstance>(context);
    final currentRoot = firebase.root.root;

    return <Widget>[
      StreamBuilder<List<FirebaseRoot>>(
        stream: firebase.roots.rootStream,
        initialData: firebase.roots.roots,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading database roots...");
          }

          final rootNames = snapshot.data.map((root) => root.name).toList();
          final empty = rootNames.isEmpty;

          if (empty) rootNames.add("no roots");

          final defaultRoot = rootNames.first;

          return DropDownSettingsTile<String>(
            title: "Database Root",
            enabled: !empty,
            settingKey: MyAppSettings.firebaseRootName,
            values: rootNames
                .asMap()
                .map((_, value) => MapEntry(value, capitalize(value))),
            selected:
                currentRoot != null && rootNames.contains(currentRoot.name)
                    ? currentRoot.name
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
              firebase.roots.getRoot(name);
            }
          }
        },
      ),
    ];
  }
}
