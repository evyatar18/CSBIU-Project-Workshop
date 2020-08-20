import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/platform/files.dart';
import 'package:workshop_digitalization/platform/platform.dart';
import 'package:workshop_digitalization/platform/web/web_html_editor.dart';

import 'web_file_manager.dart';

class WebPlatform extends PlatformSpecific {
  @override
  final String firebaseFilename = "firebase config (for web) as json";

  @override
  Widget htmlEditor(String value, Stream<Completer<String>> inputRequests) {
    return WebHtmlEditor(initialInput: value, inputRequests: inputRequests);
  }

  @override
  FirebaseOptions getFirebaseOptions(Map<String, dynamic> json) {
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

  @override
  PlatformFileManager get files => WebFileManager();
}
