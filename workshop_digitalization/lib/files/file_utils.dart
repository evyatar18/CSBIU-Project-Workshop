// gets the filename from a given `path`
import 'dart:io';

String getFilenameFromPath(String path) =>
    path.substring(path.lastIndexOf("/") + 1);

/// gets the extension from a given `path`
getTypeFromPath(String path) =>
    path.contains(".") ? path.substring(path.lastIndexOf(".") + 1) : "";

class FileCreationException {

  final String message;
  final String fileName;
  final String filePath;

  FileCreationException(this.fileName, this.filePath, {String customMessage}) :
    this.message = "Error while initializing local file $fileName at $filePath." +
    "${customMessage == null ? "" : "\n$customMessage"}";

  @override
  String toString() => message;
}

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
    throw FileCreationException(getFilenameFromPath(path), path, customMessage: e.toString());
  }
}
