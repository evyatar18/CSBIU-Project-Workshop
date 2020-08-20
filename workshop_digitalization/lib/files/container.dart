import 'dart:async';
import 'dart:io';

import 'package:workshop_digitalization/global/disposable.dart';

import 'transfer.dart';

/// Describes a file that is stored in a `FileContainer`
///
/// allows getting the file using a `FileRetrievalSnapshot`
abstract class FileInfo {
  String get path;
  String get fileName;
  String get fileType;
  int get fileSize;

  Stream<FileRetrievalSnapshot> getFile();
}

/// A container of files
///
/// includes a stream of List<FileInfo> which reports the state as files are being added, modified or deleted
abstract class FileContainer implements Disposable {
  /// reports the state as files are being added, modified or deleted
  Stream<List<FileInfo>> get files;

  /// The latest file recorded
  List<FileInfo> get latestFiles;
  bool get isLoaded;

  /// add a new file
  ///
  /// `file` holds the content of the file which will be uploaded
  ///
  /// `name` is going to be the name of the file in the storage, if it is not specified
  /// the name of `file` will be used
  ///
  /// `type` may be stored with the file as a metadata
  Stream<FileUploadSnapshot> addFile(File file, {String name, String type});

  /// Deletes the given file from the current container
  Future<void> removeFile(FileInfo file);
}
