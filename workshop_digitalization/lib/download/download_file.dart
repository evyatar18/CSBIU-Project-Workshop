import 'dart:html';

//import 'dart:io' show Platform;
import 'dart:js';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:workshop_digitalization/csv/file_IO.dart';
import 'dart:js' as js;
import 'dart:html' as html;

import 'package:workshop_digitalization/global/path_suplier.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';

class DownloadFile {
  static Future<void> download(String data, String name,
      [BuildContext context]) async {
    print('s---------------------');
    if (kIsWeb) {
      js.context.callMethod("saveAs", [
        html.Blob([data]),
        name
      ]);
    } else {
      final path = await getDownloadPath(context);
      if (path == null) {
        return;
      }
      FileIO.write(path: '$path/$name', data: data);
      showSuccessDialog(context, message: "The file saved in : $path");
    }
  }

  static Future<String> upload(String data, String name,
      [BuildContext context]) async {
    print('s---------------------');
    if (kIsWeb) {
      print(_startFilePicker().toString());
      return _startFilePicker().toString();
    } else {
      final path = await getDownloadPath(context);
      if (path == null) {
        return '';
      }
      FileIO.write(path: '$path/$name', data: data);
      showSuccessDialog(context, message: "The file saved in : $path");
    }
  }
}

String _startFilePicker()  {
  InputElement uploadInput = FileUploadInputElement();
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    // read file content as dataURL
    final files = uploadInput.files;
    if (files.length == 1) {
      final file = files[0];
      FileReader reader = FileReader();
      reader.readAsText(file);
      reader.onLoad.listen((data) {
        return reader.result.toString();
      });
      reader.onError.listen((fileEvent) {
        return "Some Error occured while reading the file";
      });
    }
    return '';
  });
  return '';
}
