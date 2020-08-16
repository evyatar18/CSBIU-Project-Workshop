import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:html_editor/html_editor.dart';
import 'package:package_info/package_info.dart';
import 'package:workshop_digitalization/platform/platform.dart';

class AndroidPlatform extends PlatformSpecific {
  PackageInfo _packageInfo;

  AndroidPlatform(this._packageInfo);

  @override
  String get firebaseFilename => "`google-services.json`";

  @override
  FirebaseOptions getFirebaseOptions(Map<String, dynamic> json) {
    // get the clients array
    final clients = (json["client"] as List).cast<Map<String, dynamic>>();

    // find the client info for this app
    final androidClient = clients.firstWhere((client) =>
        client["client_info"]["android_client_info"]["package_name"] ==
        _packageInfo.packageName);

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

  @override
  Widget htmlEditor(String value, Stream<Completer<String>> inputRequests) {
    final editorKey = GlobalKey<HtmlEditorState>();

    inputRequests.listen((req) {
      req.complete(editorKey.currentState.getText());
    });

    return HtmlEditor(
      hint: "Your text here...",
      value: value,
      key: editorKey,
      height: 400,
      decoration: BoxDecoration(),
    );
  }
}
