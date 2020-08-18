import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:workshop_digitalization/global/ui/disposer.dart';

import 'package:workshop_digitalization/global/ui/utils.dart';
import 'package:workshop_digitalization/global/strings.dart';

import 'package:workshop_digitalization/progress/progress.dart';
import 'package:workshop_digitalization/progress/progress_repo.dart';
import 'package:workshop_digitalization/progress/ui/progress_displayer.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';

import '../container.dart';
import '../transfer.dart';

/// a Scaffold which displays a file container,
class FileContainerDisplayer extends StatelessWidget {
  final FileContainer container;
  final ProgressRepository repo;

  /// Create a new `FileContainerDisplayer`
  ///
  /// `container` the `FileContainer` to display
  ///
  /// `repo` a `ProgressRepository` which will be used to report ongoing operations (ie. upload, download and deletion)
  FileContainerDisplayer({@required this.container, @required this.repo});

  @override
  Widget build(BuildContext context) {
    return ProgressScaffold(
      repo: repo,
      body: Scaffold(
        body: _buildFileList(context),
        floatingActionButton: _buildAddButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  /// Creates the ListView of the displayed files
  Widget _buildFileList(BuildContext mainScaffoldContext) {
    return StreamBuilder<List<FileInfo>>(
      initialData: container.latestFiles,
      stream: container.files,
      builder: (context, snapshot) {
        // if waiting for data
        if (!container.isLoaded) {
          return _buildLoadingData();
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, i) =>
              _buildFileTile(snapshot.data[i], mainScaffoldContext),
        );
      },
    );
  }

  /// Creates the `Loading Data` widget which is displayed while file data is being loaded
  Widget _buildLoadingData() {
    return Container(
      padding: EdgeInsets.all(20),
      child: LabeledCircularLoader(
        labels: ["Loading data..."],
      ),
    );
  }

  // Create the corresponding `ListTile` for a given `FileInfo` instance
  Widget _buildFileTile(FileInfo info, BuildContext mainScaffoldContext) {
    return ListTile(
      title: Text(info.fileName),
      subtitle: Text("${byteSizeString(info.fileSize)} | ${info.fileType}"),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => _removeFile(info, mainScaffoldContext),
      ),
      onTap: () => _openFile(info),
    );
  }

  Widget _buildAddButton() {
    return Builder(builder: (context) {
      return FloatingActionButton(
        heroTag: makeHerotag(),
        onPressed: () => _addFiles(context),
        child: Icon(Icons.add),
      );
    });
  }

  Future<void> _removeFile(FileInfo file, BuildContext context) async {
    // create initial snapshot
    final id = await repo.createId(
        ProgressSnapshot("Deleting ${file.fileName}", "deleting...", 0.5));

    try {
      // request file removal from container
      await container.removeFile(file);

      // notify by SnackBar when the file was deleted
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Deleted ${file.fileName} successfully.")));

      // push `success` update for the deletion snapshot
      repo.pushUpdate(
        id,
        ProgressSnapshot(
            "Deleting ${file.fileName}", "deleted successfully!", 1),
      );
    } catch (e) {
      // push `error update`
      repo.pushUpdate(
        id,
        ProgressSnapshot(
            "Deleting ${file.fileName}", "failed deleting. exception: $e", 0.5,
            failed: true),
      );
    } finally {
      // remove the snapshot from the repository after 1 second
      await Future.delayed(Duration(seconds: 1));
      repo.removeId(id);
    }
  }

  Future<void> _addFiles(BuildContext context) async {
    // TODO change this when possible
    // currently the firebase storage only supports the `File` class so for web
    // this will not work
    final files = await FilePicker.getMultiFile();

    if (files == null) {
      showSnackbarMessage(context, "no files selected");
      return;
    }

    // upload files, and get upload stream for each file
    final uploads = files.map((file) => container.addFile(file));

    // convert the upload streams to progress streams
    final uploadsAsProgress = uploads.map(
      (stream) => stream.map((fs) =>
          fileTransferAsProgress(fs, taskName: "Uploading ${fs.fileName}")),
    );

    // for each created progress stream, insert it into the repository
    uploadsAsProgress.forEach(repo.feed);

    showSnackbarMessage(context, "uploading files...");
  }

  Future<void> _openFile(FileInfo info) async {
    // download file
    final download = info.getFile().asBroadcastStream();

    // convert the file transfer to progress instance
    final progress = download.map((fs) =>
        fileTransferAsProgress(fs, taskName: "Downloading ${fs.fileName}"));

    int taskId = await repo.feed(progress);

    try {
      final retreival = await info.getFile().first;
      final file = await retreival.file;
      await OpenFile.open(file.path);
    } catch (e) {
      print("error occurred on _openFile file_view.dart:: $e");
    } finally {
      // remove snapshot from repository after download and opening complete
      repo.removeId(taskId);
    }
  }
}

Widget createFileContainerDisplayer({@required FileContainer container}) {
  return Disposer<ProgressRepository>(
    create: () => ProgressRepository(),
    builder: (context, repo) =>
        FileContainerDisplayer(container: container, repo: repo),
  );
}
