import 'dart:async';
import 'dart:io';

import 'package:workshop_digitalization/models/disposable.dart';

import 'transfer.dart';

abstract class FileInfo {
  String get path;
  String get fileName;
  String get fileType;
  int get fileSize;

  Stream<FileRetrievalSnapshot> getFile();
}

abstract class FileContainer implements Disposable {
  Stream<List<FileInfo>> get files;
  List<FileInfo> get latestFiles;

  Stream<FileUploadSnapshot> addFile(File f, {String name, String type});
  Future<void> removeFile(FileInfo file);
}
