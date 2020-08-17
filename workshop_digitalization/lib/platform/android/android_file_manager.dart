import 'package:workshop_digitalization/platform/files.dart';

class AndroidFileManager implements PlatformFileManager {
  @override
  Future<List<PlatformFile>> chooseFiles(
      [List<String> extensions, bool multiple = true]) {
    // TODO: implement chooseFiles
    throw UnimplementedError();
  }

  @override
  Stream<int> saveFile(PlatformFile file, [String directory]) {
    // TODO: implement saveFile
    throw UnimplementedError();
  }
}
