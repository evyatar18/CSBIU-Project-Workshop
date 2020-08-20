// gets the filename from a given `path`
import 'dart:io';

import 'package:workshop_digitalization/files/container.dart';

String getFilenameFromPath(String path) =>
    path.substring(path.lastIndexOf("/") + 1);

/// gets the extension from a given `path`
String getTypeFromPath(String path) =>
    path.contains(".") ? path.substring(path.lastIndexOf(".") + 1) : "";

class FileCreationException {
  final String message;
  final String fileName;
  final String filePath;

  FileCreationException(this.fileName, this.filePath, {String customMessage})
      : this.message =
            "Error while initializing local file $fileName at $filePath." +
                "${customMessage == null ? "" : "\n$customMessage"}";

  @override
  String toString() => message;
}

/// creates a file at the given path and returns it
File createFileSync(String path) {
  final localFile = File(path);

  try {
    // delete local file if exists
    if (localFile.existsSync()) {
      localFile.deleteSync();
    }

    // create from zero
    localFile.createSync(recursive: true);

    return localFile;
  } catch (e) {
    throw FileCreationException(
      getFilenameFromPath(path),
      path,
      customMessage: e.toString(),
    );
  }
}

/// clears a given file container
Future<void> clearFileContainer(FileContainer fc) async {
  final fileDeletions = fc.latestFiles.map((fi) => fc.removeFile(fi));

  for (final deletionFuture in fileDeletions) {
    try {
      await deletionFuture;
    } catch (e) {
      print("error deleting file: $e");
    }
  }

  await fc.dispose();
}
