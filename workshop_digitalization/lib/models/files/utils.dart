import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/foundation.dart';
import 'package:workshop_digitalization/models/files/transfer.dart';

String getFilenameFromPath(String path) =>
    path.substring(path.lastIndexOf("/") + 1);

getTypeFromPath(String path) =>
    path.contains(".") ? path.substring(path.lastIndexOf(".") + 1) : "";

Stream<FileRetrievalSnapshot> downloadFirebaseFile(
    {@required StorageReference fileRef,
    @required String downloadPath,
    @required String fileName}) {
  final localFile = File(downloadPath);

  try {
    // delete local file if exists
    if (localFile.existsSync()) {
      localFile.deleteSync();
    }

    // create from zero
    localFile.createSync(recursive: true);
  } catch (e) {
    print("Error while initializing local file: $e");
    return Stream.value(FileRetrievalSnapshot.error(fileName));
  }

  // do the actual download, in the future we hope to have a stream which reports download progress
  Future<FileRetrievalSnapshot> download() async {
    final downloadTask = fileRef.writeToFile(localFile);

    try {
      final result = await downloadTask.future;

      return FileRetrievalSnapshot(
        FileTransferStatus.SUCCESS,
        result.totalByteCount,
        result.totalByteCount,
        fileName,
        Future.value(localFile),
      );
    } catch (ex) {
      await localFile.delete();
      return FileRetrievalSnapshot.error(fileName);
    }
  }

  return Stream.fromFuture(download());
}

Future<StorageFile> uploadFirebaseFile(
    Storage storageReference, String storagePath, File f,
    {String name, String type}) async {
  if (type == null) {
    return await storageReference.save(storagePath, f, fileName: name);
  } else {
    return await storageReference.save(storagePath, f,
        fileName: name, mimeType: type);
  }
}

Stream<FileUploadSnapshot> convertUploaderStream(
    Stream<StorageTaskEvent> uploaderStream) {
  var onComplete = () async {
    await for (var update in uploaderStream) {
      if (update.type == StorageTaskEventType.failure ||
          update.type == StorageTaskEventType.success) {
        break;
      }
    }
  }();

  return uploaderStream.map((event) {
    final fileName = getFilenameFromPath(event.snapshot.ref.path);

    var status;

    switch (event.type) {
      case StorageTaskEventType.failure:
        return FileUploadSnapshot.error(fileName);
      case StorageTaskEventType.resume:
      case StorageTaskEventType.progress:
      case StorageTaskEventType.pause:
        {
          status = FileTransferStatus.IN_PROGRESS;
          break;
        }

      case StorageTaskEventType.success:
        {
          status = FileTransferStatus.SUCCESS;
          break;
        }
    }

    return FileUploadSnapshot(status, event.snapshot.bytesTransferred,
        event.snapshot.totalByteCount, fileName, onComplete);
  });
}
