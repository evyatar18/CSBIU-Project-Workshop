import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:package_info/package_info.dart';
import 'dart:io' show Platform;

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
  final apiKey = androidClient["api_key"]["current_key"];
  final projectID = androidClient["project_info"]["project_id"];
  final databaseURL = androidClient["project_info"]["firebase_url"];
  final storageBucket = androidClient["project_info"]["storage_bucket"];

  // create a `FirebaseOptions` instance
  return FirebaseOptions(
    googleAppID: googleAppID,
    apiKey: apiKey,
    projectID: projectID,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
  );
}

Future<FirebaseOptions> generateOptions(String data) async {
  if (Platform.isAndroid) {
    final json = jsonDecode(data);
    final info = await PackageInfo.fromPlatform();

    return generateAndroidFirebaseOptions(info, json);
  }

  throw UnsupportedError("Current operating system: "
      "${Platform.operatingSystem} is not supported.");
}
