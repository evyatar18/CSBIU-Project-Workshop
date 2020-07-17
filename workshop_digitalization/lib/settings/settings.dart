import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../firebase_consts/lib.dart' as globs;

class MyAppSettings {
  static const String firebaseRootName = "firebase-root";

  static String getDefaultRoot(List<String> versions) {
    return versions.isEmpty ? DateTime.now().year.toString() : versions[0];
  }

  static Future<String> get defaultRoot async {
    try {
      final roots = globs.roots.roots ?? await globs.roots.rootStream.first;
      final versions = roots.map((root) => root.reference.documentID).toList();
      return getDefaultRoot(versions);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static void setRoot(String root) {
    Settings.setValue(firebaseRootName, root);
  }
}
