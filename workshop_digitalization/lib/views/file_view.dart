import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:workshop_digitalization/models/files/container.dart';
import 'package:workshop_digitalization/models/files/transfer.dart';
import 'package:workshop_digitalization/views/disposer.dart';
import 'package:workshop_digitalization/views/progress/progress.dart';
import 'package:workshop_digitalization/views/progress/progress_displayer.dart';
import 'package:workshop_digitalization/views/progress/progress_repo.dart';
import 'package:workshop_digitalization/views/view_utils.dart';

class FileContainerDisplayer extends StatelessWidget {
  final FileContainer container;
  final ProgressRepository repo;

  FileContainerDisplayer({@required this.container, @required this.repo});

  static String _sizeAsString(int bytes) {
    int kb = 1000;
    int mb = kb * kb;

    if (bytes >= mb) {
      var displayedSize = (bytes * 10 / mb).round() / 10;
      return "${displayedSize}MB";
    } else if (bytes >= kb) {
      var displayedSize = (bytes * 10 / kb).round() / 10;
      return "${displayedSize}KB";
    } else {
      return "${bytes}B";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProgressScaffold(repo: repo, body: _buildFileList()),
      floatingActionButton: _buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFileList() {
    return StreamBuilder<List<FileInfo>>(
      stream: container.files,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingData();
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, i) => _buildFileTile(snapshot.data[i]),
        );
      },
    );
  }

  Widget _buildLoadingData() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("Loading data...")
          ],
        ),
      ),
    );
  }

  Widget _buildFileTile(FileInfo info) {
    return Builder(builder: (context) {
      return ListTile(
        title: Text(info.fileName),
        subtitle: Text("${_sizeAsString(info.fileSize)} | ${info.fileType}"),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _removeFile(info, context),
        ),
        onTap: () => _openFile(info),
      );
    });
  }

  Widget _buildAddButton() {
    return Builder(builder: (context) {
      return FloatingActionButton(
        onPressed: () => _addFiles(context),
        child: Icon(Icons.add),
      );
    });
  }

  Future<void> _removeFile(FileInfo file, BuildContext context) async {
    final id = await repo.createId(
        ProgressSnapshot("Deleting ${file.fileName}", "deleting...", 0.5));

    try {
      await container.removeFile(file);
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Deleted ${file.fileName} successfully.")));

      repo.pushUpdate(
        id,
        ProgressSnapshot(
            "Deleting ${file.fileName}", "deleted successfully!", 1),
      );
    } catch (e) {
      repo.pushUpdate(
        id,
        ProgressSnapshot(
            "Deleting ${file.fileName}", "failed deleting. exception: $e", 0.5,
            failed: true),
      );
    } finally {
      await Future.delayed(Duration(seconds: 1));
      repo.removeId(id);
    }
  }

  Future<void> _addFiles(BuildContext context) async {
    final files = await FilePicker.getMultiFile();

    if (files == null) {
      showSnackbarMessage(context, "no files selected");
      return;
    }

    // upload files, and get upload stream for each file
    final uploads = files.map((file) => container.addFile(file));

    // convert the upload streams to progress streams
    final uploadsAsProgress = uploads.map((stream) => stream.map((fs) =>
        fileTransferAsProgress(fs, taskName: "Uploading ${fs.fileName}")));

    uploadsAsProgress.forEach((fs) => feedStream(repo, fs));

    showSnackbarMessage(context, "uploading files...");
  }

  Future<void> _openFile(FileInfo info) async {
    final download = info.getFile().asBroadcastStream();

    final progress = download.map((fs) =>
        fileTransferAsProgress(fs, taskName: "Downloading ${fs.fileName}"));

    int taskId = await feedStream(repo, progress);

    try {
      final retreival = await info.getFile().first;
      final file = await retreival.file;
      await OpenFile.open(file.path);
    } catch (e) {
      print("error occurred on _openFile file_view.dart:: $e");
    } finally {
      repo.removeId(taskId);
    }
  }
}

ProgressSnapshot fileTransferAsProgress(FileTransferSnapshot fs,
    {String taskName = null}) {
  return ProgressSnapshot(
    "${taskName ?? fs.fileName}",
    fs.message,
    fs.bytesTransferred / fs.totalByteCount,
    failed: (fs.status == FileTransferStatus.ERROR),
  );
}
