import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;

import 'package:workshop_digitalization/platform/files.dart';

class WebFileManager implements PlatformFileManager {
  @override
  Future<List<PlatformFile>> chooseFiles(
      [List<String> extensions, bool multiple = true]) async {
    // if returns null, use an empty list
    final htmlFiles = await _openFilesDialog(extensions, multiple);
    return Future.wait(htmlFiles.map(_createPlatformFile));
  }

  @override
  Stream<int> saveFile(PlatformFile file, [String directory]) async* {
    // ignoring directory TODO allow saving in directory?

    // nothing saved up to now
    yield 0;

    // TODO if blob size is too big, we'll have to switch to StreamSaver:
    // https://github.com/jimmywarting/StreamSaver.js

    // using the saveAs from https://github.com/eligrey/FileSaver.js
    final blob = html.Blob([await file.data.join("")]);
    js.context.callMethod("saveAs", [blob, file.name]);

    // done saving
    yield blob.size;
  }

  /// Opens up the file dialog with the given settings
  /// and returns the chosen files
  Future<List<html.File>> _openFilesDialog(List<String> extensions, bool multiple) {
    html.InputElement uploadInput = html.FileUploadInputElement();

    if (extensions != null) {
      uploadInput.accept = extensions
          .map((ext) => ext.startsWith(".") ? ext : ".$ext")
          .join(",");
    }

    uploadInput.multiple = multiple;
    uploadInput.click();

    final files = Completer<List<html.File>>();
    final listener = uploadInput.onChange.listen(
      (_) => files.complete(uploadInput.files ?? <html.File>[]),
    );

    files.future.whenComplete(listener.cancel);
    return files.future;
  }

  /// creates a _WebFile from a given html file
  Future<PlatformFile> _createPlatformFile(html.File htmlFile) {
    var reader = html.FileReader();

    final out = reader.onLoad
        .map((event) => MemoryFile.fromString(htmlFile.name, reader.result.toString()))
        .first;
    reader.readAsText(htmlFile, "UTF-8");

    // mark for garbage collection
    out.whenComplete(() => reader = null);

    return out;
  }
}