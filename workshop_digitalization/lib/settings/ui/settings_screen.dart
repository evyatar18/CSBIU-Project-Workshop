import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:workshop_digitalization/firebase.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/settings/settings.dart';

class AppSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SettingsScreen(
        title: "Application Settings",
        children: [
          SettingsGroup(
            title: "",
            children: [
              FutureBuilder<List<String>>(
                future: getVersions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("Loading database versions...");
                  }

                  final versions = snapshot.data;

                  return DropDownSettingsTile<String>(
                    title: "Database Root",
                    settingKey: MyAppSettings.firebaseRootName,
                    values: versions
                        .asMap()
                        .map((_, value) => MapEntry(value, capitalize(value))),
                    selected: versions.contains(currentVersion)
                        ? currentVersion
                        : MyAppSettings.getDefaultRoot(versions),
                    onChange: MyAppSettings.setRoot,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
