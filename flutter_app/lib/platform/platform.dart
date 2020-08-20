// interface providing functionality of the different platforms

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'files.dart';

final _nameRegex = RegExp("^\\s*(\\w+):", multiLine: true);

String _preprocessJson(String data) {
  // make sure every name is surrounded by ""
  return data.splitMapJoin(_nameRegex, onMatch: (match) {
    final name = match.group(1);
    return '"$name":';
  });
}

abstract class PlatformSpecific {
  /// The message to display on the database choice page
  String get firebaseFilename;

  /// Parses the firebase options according to the current platform
  FirebaseOptions getFirebaseOptions(Map<String, dynamic> json);

  FirebaseOptions parseFirebaseOptions(String jsonString) {
    final json = jsonDecode(_preprocessJson(jsonString));
    return getFirebaseOptions(json);
  }

  /// The html editor for this platform
  ///
  /// `value` holds the initial value inside the editor
  ///
  /// `inputRequests` is a stream of input requests. When the editor gets a request, it is expected to complete the completer
  /// with the current input
  ///
  /// TODO maybe remove this, this is currently not used anywhere (was used in the past)
  Widget htmlEditor(String value, Stream<Completer<String>> inputRequests);

  /// Get the file manager of this platform
  PlatformFileManager get files;
}
