import 'package:directory_picker/directory_picker.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:path_provider/path_provider.dart';

import '../firebase_consts/lib.dart' as globs;

class MyAppSettings {
  static const String firebaseRootName = "firebase-root";
  static const String defaultDownloadPathName = "download-path";
  static const String defaultDownloadPathEnabeld = "download-path-switch";


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
      return await Settings.getValue(
          defaultDownloadPathEnabeld, false);
    } catch (e) {
      print(e);
      return null;
    }
  }
  
  static Future<void> setdefaultDownloadPath(String path) async {
    Settings.setValue(defaultDownloadPathName, path);
  }
}

