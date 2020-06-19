import 'dart:io';

import 'package:flutter/material.dart';


class FileIO {
  static void write({@required String path,@required String data}) async {
    final File file = await File(path).create();
    // Write the file.
    await file.writeAsString(data);
  }
}