import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:package_info/package_info.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Generates a `FirebaseOptions` instance from a given `google-services.json` structured json
FirebaseOptions generateAndroidFirebaseOptions(
    PackageInfo packageInfo, Map<String, dynamic> json) {
  // get the clients array
  final clients = (json["client"] as List).cast<Map<String, dynamic>>();

  // find the client info for this app
  final androidClient = clients.firstWhere((client) =>
      client["client_info"]["android_client_info"]["package_name"] ==
      packageInfo.packageName);

  // get android data
  final googleAppID = androidClient["client_info"]["mobilesdk_app_id"];
  final apiKey = androidClient["api_key"].last["current_key"];
  final projectID = json["project_info"]["project_id"];
  final databaseURL = json["project_info"]["firebase_url"];
  final storageBucket = json["project_info"]["storage_bucket"];

  // create a `FirebaseOptions` instance
  return FirebaseOptions(
    googleAppID: googleAppID,
    apiKey: apiKey,
    projectID: projectID,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
  );
}

FirebaseOptions generateWebFirebaseOptions(Map<String, dynamic> json) {
/*
{
  apiKey: "AIzaSyCfuMAlUZvUNviuU9-1_pvCfEYSI40RMP4",
  authDomain: "workshop-a85eb.firebaseapp.com",
  databaseURL: "https://workshop-a85eb.firebaseio.com",
  projectId: "workshop-a85eb",
  storageBucket: "workshop-a85eb.appspot.com",
  messagingSenderId: "818805500247",
  appId: "1:818805500247:web:63c948a6a1199fe09e3612",
  measurementId: "G-Q4QLWZ7CW5"
};
*/
  final apiKey = json["apiKey"];
  final googleAppID = json["appId"];
  final dbUrl = json["databaseURL"];
  final projectId = json["projectId"];
  final storageBucket = json["storageBucket"];

  return FirebaseOptions(
    googleAppID: googleAppID,
    apiKey: apiKey,
    databaseURL: dbUrl,
    projectID: projectId,
    storageBucket: storageBucket,
  );
}

final nameRegex = RegExp("^\\s*(\\w+):", multiLine: true);

String preprocessJson(String data) {
  // make sure every name is surrounded by ""
  return data.splitMapJoin(nameRegex, onMatch: (match) {
    final name = match.group(1);
    return '"$name":';
  });
}

Future<FirebaseOptions> generateOptions(String data) async {
  final json = jsonDecode(preprocessJson(data));

  if (kIsWeb) {
    return generateWebFirebaseOptions(json);
  } else if (Platform.isAndroid) {
    final info = await PackageInfo.fromPlatform();

    return generateAndroidFirebaseOptions(info, json);
  }

  throw UnsupportedError("Current operating system: "
      "${Platform.operatingSystem} is not supported.");
}

String getFirebaseFilename() {
  if (kIsWeb) {
    return "firebaseConfig (for web)";
  } else if (Platform.isAndroid) {
    return "google-services.json";
  }

  return "cannot copy, unsupported os";
}
