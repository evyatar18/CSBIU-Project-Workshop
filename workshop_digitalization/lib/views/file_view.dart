import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:workshop_digitalization/models/files/container.dart';

class FileContainerDisplayer extends StatelessWidget {
  final FileContainer container;

  FileContainerDisplayer({@required this.container});

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

  Widget _buildFileCard(FileInfo info) {
    return Builder(builder: (context) {
      return ListTile(
        title: Text(info.fileName),
        subtitle: Text("${_sizeAsString(info.fileSize)} | ${info.fileType}"),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            () async {
              await container.removeFile(info);
              // Scaffold.of(context).showSnackBar(SnackBar(
              //     content: Text("Deleted ${info.fileName} successfully.")));
            }();
          },
        ),
        onTap: () {
          _openFile(info);
          // showDialog(context: null, barrierDismissible: )
        },
      );
    });
  }

  Widget _buildFileList() {
    return StreamBuilder<List<FileInfo>>(
      stream: container.files,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
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

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, i) => _buildFileCard(snapshot.data[i]),
        );
      },
    );
  }

  Future<void> _addFiles(void Function(String message) showSnackbar) async {
    final files = await FilePicker.getMultiFile();

    if (files == null) {
      showSnackbar("no files selected");
      return;
    }

    var uploads = files.map((file) => container.addFile(file));
    showSnackbar("uploading files...");

    for (var upload in uploads) {
      var file =  (await upload.first);
      await file.onComplete;

      showSnackbar("uploaded file ${file.fileName}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildFileList(),
      floatingActionButton: Builder(builder: (context) {
        void showSnackbar(String message) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
        }

        return FloatingActionButton(
          onPressed: () {
            _addFiles(showSnackbar);
          },
          child: Icon(Icons.add),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Future<void> _openFile(FileInfo info) async {
  try {

    final firstInfo = await info.getFile().first;
    final file = await firstInfo.file;


    await OpenFile.open(file.path);
  } catch (e) {
    print("error occurred $e");
  }
}
