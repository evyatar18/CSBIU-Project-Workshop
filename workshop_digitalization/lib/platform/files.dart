import 'dart:async';

/// represents a general file (supported by all platforms)
abstract class PlatformFile {
  /// name of the file
  String get name;

  /// data from the file
  Stream<String> get data;

  /// release file resources
  Future<void> dispose();
}

final _lineSplitter = RegExp("[\r\n]+");

extension GetLines on PlatformFile {
  /// get lines from the platform file
  Stream<String> get lines =>
      data.map((event) => event.split(_lineSplitter)).expand((split) => split);
}

abstract class PlatformFileManager {
  /// Saves the given `PlatformFile` at the given directory
  ///
  /// Returns a stream with the amount of lines saved up to now. The stream
  /// may throw errors.
  ///
  /// `file` is the file to be saved
  ///
  /// `directory` is the directory at which the file should be saved,
  /// if it is not specified - the default location for the current
  /// platform is used
  Stream<int> saveFile(PlatformFile file, [String directory]);

  /// Opens the file choice dialog at the current platform
  ///
  /// `extensions` are the allowed extensions for the files
  /// if null, any extension is allowed
  ///
  /// if `multiple` is `true`, opens the dialog for multiple files.
  /// otherwise, only a single file will be used.
  Future<List<PlatformFile>> chooseFiles(
      [List<String> extensions, bool multiple = true]);
}

extension ChooseSingleFile on PlatformFileManager {
  /// Opens the file choice dialog at the current platform for a single
  /// file
  ///
  /// `extensions` are the allowed extensions for the files
  /// if null, any extension is allowed
  Future<PlatformFile> chooseFile([List<String> extensions]) async {
    final files = await chooseFiles(extensions, false);

    if (files != null && files.isNotEmpty) {
      return files[0];
    }

    return null;
  }
}

class MemoryFile implements PlatformFile {
  final String _name;
  List<String> _data;

  MemoryFile(this._name, this._data);

  factory MemoryFile.fromString(String name, String data) {
    return MemoryFile(name, [data]);
  }

  @override
  Stream<String> get data => Stream.fromIterable(_data);

  @override
  Future<void> dispose() {
    _data?.clear();
    _data = null;
    return Future.value();
  }

  @override
  String get name => _name;
}
