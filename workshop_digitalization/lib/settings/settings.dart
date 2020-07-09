import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../firebase.dart';

class MyAppSettings {
  static const String firebaseRootName = "firebase-root";

  static String getDefaultRoot(List<String> versions) {
    return versions.isEmpty ? DateTime.now().year.toString() : versions[0];
  }

  static Future<String> get defaultRoot async {
    final docs = await firestoreRootCollection.limit(1).getDocuments();
    final versions = docs.documents.map((doc) => doc.documentID).toList();

    return getDefaultRoot(versions);
  }

  static void setRoot(String root) {
    Settings.setValue(firebaseRootName, root);
  }
}
