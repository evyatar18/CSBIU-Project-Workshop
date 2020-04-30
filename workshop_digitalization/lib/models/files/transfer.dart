import 'dart:io';

enum FileTransferStatus { WAITING, IN_PROGRESS, SUCCESS, ERROR }

abstract class FileTransferSnapshot {
  FileTransferStatus get status;

  int get totalByteCount;
  int get bytesTransferred;

  String _msg;
  String get message => _msg ?? (_msg = _generateMessage(status, bytesTransferred, totalByteCount));

  String get fileName;
}

String _generateMessage(FileTransferStatus status, int bytesTransferred, int totalByteCount) {
    if (status == null) {
      return "";
    }

    switch (status) {
      case FileTransferStatus.WAITING:
        return "waiting";
      case FileTransferStatus.IN_PROGRESS:
        {
          final percents = (100 * bytesTransferred / totalByteCount).round();
          return "in progress $bytesTransferred/$totalByteCount retrieved ($percents%).";
        }
      case FileTransferStatus.SUCCESS:
        return "complete";
      case FileTransferStatus.ERROR:
        return "error transferring file";
    }

    return "";
  }


class FileRetrievalSnapshot extends FileTransferSnapshot {
  final FileTransferStatus status;

  final int totalByteCount;
  final int bytesTransferred;

  final String fileName;

  final Future<File> file;

  FileRetrievalSnapshot(this.status, this.bytesTransferred, this.totalByteCount,
      this.fileName, this.file);

  factory FileRetrievalSnapshot.error(String fileName) =>
    FileRetrievalSnapshot(FileTransferStatus.ERROR, 0, -1, fileName, Future.value(null));
}

class FileUploadSnapshot extends FileTransferSnapshot {
  @override
  final int bytesTransferred;

  @override
  final String fileName;

  @override
  final FileTransferStatus status;

  @override
  final int totalByteCount;

  final Future<void> onComplete;

  FileUploadSnapshot(this.status, this.bytesTransferred, this.totalByteCount,
      this.fileName, this.onComplete);

  factory FileUploadSnapshot.error(String fileName) =>
    FileUploadSnapshot(FileTransferStatus.ERROR, 0, -1, fileName, Future<void>.value());
}
