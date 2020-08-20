import 'dart:io';

import 'package:directory_picker/directory_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workshop_digitalization/settings/settings.dart';

Future<String> getDownloadPath(BuildContext context) async {
  // if there is default path to download
  if (await MyAppSettings.getDefaultDownloadPathEnabled) {
    return await MyAppSettings.defaultDownloadPath;
  } else {
    // pick a directory
    Directory directory = await DirectoryPicker.pick(
        context: context, rootDirectory: await getExternalStorageDirectory());
    if (directory != null) {
      return directory.path;
    } else {
      return null;
    }
  }
}
