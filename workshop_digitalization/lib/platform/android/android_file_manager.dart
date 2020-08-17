import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:workshop_digitalization/platform/files.dart';

class AndroidFileManager implements PlatformFileManager {
  @override
  Future<List<PlatformFile>> chooseFiles(
      [List<String> extensions, bool multiple = true]) async {
    final files = multiple
        ? await FilePicker.getMultiFile(allowedExtensions: extensions)
        : [await FilePicker.getFile(allowedExtensions: extensions)];

    return files.map((e) => _AndroidFile(e)).toList();
  }

  @override
  Stream<int> saveFile(PlatformFile file, [String directory]) async* {
    yield 0;

    final path = directory == null ? file.name : "$directory/${file.name}";
    final androidFile = File(path);

    if (await androidFile.exists()) {
      await androidFile.delete();
    }

    await androidFile.create(recursive: true);

    int accumulatedLength = 0;
    await for (final data in file.data) {
      await androidFile.writeAsString(data, mode: FileMode.append);
      yield (accumulatedLength += data.length);
    }
  }
}

class _AndroidFile implements PlatformFile {
  File _file;

  _AndroidFile(this._file);

  @override
  Stream<String> get data => Stream.fromFuture(_file.readAsString());

  @override
  Future<void> dispose() {
    _file = null;
    return Future.value();
  }

  @override
  String get name => _file.path.split("/").last;
}
