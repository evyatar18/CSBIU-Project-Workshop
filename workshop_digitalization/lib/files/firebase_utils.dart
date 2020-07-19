import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flamingo/flamingo.dart';
import 'package:flutter/foundation.dart';
import 'transfer.dart';

///
/// downloads a file from the firebase storage
///
/// `fileRef` a reference to the file on the online storage
///
/// `downloadPath` the path the file should be downloaded to
Stream<FileRetrievalSnapshot> downloadFirebaseFile(
    {@required StorageReference fileRef,
    @required File localFile,
    @required String fileName}) {
  // do the actual download, in the future we hope to have a stream which reports download progress
  // TODO:: when there's a stream which reports donwload progress, use it
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

  // create download task
  final down = download();

  // based on the download task, create the first snapshot.
  // we have to wait until the download task completes and then we return the file
  final file = down.then((val) => val.file);
  final initialSnapshot = FileRetrievalSnapshot(
      FileTransferStatus.IN_PROGRESS, 0, 1, fileName, file);

  // TODO:: currently just 2 snapshots because the firebase API does not support yet
  // progress snapshots on downloads
  return Stream.fromFutures([Future.value(initialSnapshot), down]);
}

///
/// Converts a `Stream<StorageTaskEvent>` to a corresponding `Stream<FileUploadSnapshot>`
///
Stream<FileUploadSnapshot> convertUploaderStream(
    String fileName, Stream<StorageTaskEvent> uploaderStream) async* {
  uploaderStream = uploaderStream.asBroadcastStream();
  // this future completes when the upload is done (failure/success)
  final onComplete = uploaderStream.singleWhere((event) => event.type == StorageTaskEventType.failure ||
    event.type == StorageTaskEventType.success).then((val) {});

  try {
    // wait for events from the uploader stream
    await for (var event in uploaderStream) {
      var status;

      switch (event.type) {
        case StorageTaskEventType.failure:
          // report error
          yield FileUploadSnapshot.error(fileName, "Failed uploading $fileName;\n error code: ${event.snapshot.error}");
          return;
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

      // report normal upload event
      yield FileUploadSnapshot(status, event.snapshot.bytesTransferred,
          event.snapshot.totalByteCount, fileName, onComplete);
    }
  } catch (e) {
    // report error
    yield FileUploadSnapshot.error(fileName);
  }
}
