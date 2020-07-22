import 'dart:convert';

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:path_provider/path_provider.dart';

class MyAppSettings {
  static const String firebaseRootName = "firebase-root";
  static const String defaultDownloadPathName = "download-path";
  static const String defaultDownloadPathEnabeld = "download-path-switch";

  static String getDefaultRootName(List<String> versions) {
    return versions.isEmpty ? DateTime.now().year.toString() : versions[0];
  }

  static void setRoot(String root) {
    Settings.setValue(firebaseRootName, root);
  }

  static Future<String> get defaultDownloadPath async {
    try {
      return await Settings.getValue(
          defaultDownloadPathName, (await getExternalStorageDirectory()).path);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<bool> get getDefaultDownloadPathEnabled async {
    try {
      return await Settings.getValue(defaultDownloadPathEnabeld, false);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<void> setdefaultDownloadPath(String path) async {
    Settings.setValue(defaultDownloadPathName, path);
  }

  static void setFirebaseOptions(Map<String, dynamic> optionsMap) {
    Settings.setValue("firebase-options", jsonEncode(optionsMap));
  }

  static Map<String, dynamic> getFirebaseOptions() {
    final jsonString = Settings.getValue("firebase-options", "");
    return jsonString == "" ? null : jsonDecode(jsonString);
  }

  static String get email => Settings.getValue("email", "");
  static set email(String s) => Settings.setValue("email", s);

  static String get password => Settings.getValue("password", "");
  static set password(String s) => Settings.setValue("password", s);

  static bool get savingPassword => Settings.getValue("save_password", false);
  static set savingPassword(bool b) => Settings.setValue("save_password", b);
}
