import 'dart:io';

class FileWriter {
  static void write(String path,String data) async {
    final File file = await File(path).create();
    // Write the file.
    await file.writeAsString(data);
  }
}