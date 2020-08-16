import 'dart:convert';
import 'dart:html' as html;
import 'dart:io' as io;
import 'dart:typed_data';


import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workshop_digitalization/global/ui/disposer.dart';
import 'package:workshop_digitalization/progress/progress.dart';
import 'package:workshop_digitalization/progress/progress_repo.dart';
import 'package:workshop_digitalization/progress/ui/progress_displayer.dart';
import 'package:workshop_digitalization/student_project/student/local_student.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import '../file_parser.dart';

class LoadScreen extends StatefulWidget {
  final StudentManager studentManager;

  LoadScreen({
    @required this.studentManager,
  });
  @override
  _LoadScreenState createState() => _LoadScreenState();
}

enum FilesListState { BEFORE, WHILE, AFTER }

class _LoadScreenState extends State<LoadScreen> {
  ProgressRepository repo;
  List<io.File> _files;
  String _extension = 'csv';
  bool _loadingPath = false;
  Stream<ProgressSnapshot> progressSnapshot;

  Future<List<io.File>> openFileExplorerAndroid() async {
    var _paths = await FilePicker.getMultiFilePath(
        type: FileType.custom,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null);
    return _paths.entries.map((e) => io.File(e.value)).toList();
  }

List<int> _selectedFile;
Uint8List _bytesData;

 startWebFilePicker() async {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files[0];
      final reader = new html.FileReader();

      reader.onLoadEnd.listen((e) {
        _handleResult(reader.result);
      });
      reader.readAsDataUrl(file);
    });
  }

  void _handleResult(Object result) {
    setState(() {
      print("dsgdfag");
      _bytesData = Base64Decoder().convert(result.toString().split(",").last);
      _selectedFile = _bytesData;
    });}



  void _read2() {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        final reader = new html.FileReader();

        reader.onLoadEnd.listen((e) {
          Uint8List uploadedImage = reader.result;
          print(new String.fromCharCodes(uploadedImage));
          _files = [io.File(reader.result)];
        });
        reader.readAsDataUrl(file);
      }
    });
  }

  void _read() {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        final reader = new html.FileReader();
        reader.onLoadEnd.listen((e) {
          print("loaded: ${file.name}");
          print("type: ${reader.result.runtimeType}");
        });
        reader.onError.listen((e) {
          print(e);
        });
        reader.readAsArrayBuffer(file);
      }
    });
  }

  String _startFilePicker() {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();
    print('1');

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      print(2);
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        html.FileReader reader = html.FileReader();
        reader.readAsText(file);
        print(3);
        reader.onLoad.listen((data) {
          return reader.result.toString();
        });
        print(4);
        reader.onError.listen((fileEvent) {
          return "Some Error occured while reading the file";
        });
      }
      return 'here';
    });
    return 'here2';
  }

  //this widget open the file explorer for choose csv files
  Future<void> _openFileExplorer() async {
    setState(() => _loadingPath = true);
    if (kIsWeb) {
      await startWebFilePicker();
      print(_selectedFile);
      print(_files);
      // print(_startFilePicker());
    } else {
      try {
        openFileExplorerAndroid();
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
    }

    if (!mounted) return;
    setState(() {
      _loadingPath = false;
    });
  }

  Future<void> loadFiles(ProgressRepository progressRepository) async {
    FileParser parser = CsvFileParser();
    List<Map<String, dynamic>> jsons = [];
    if (_files != null) {
      var fields = LocalStudent.getFields();
      for (var file in _files) {
        jsons = jsons..addAll(await parser.parse(file, fields));
      }
      List<Student> students =
          jsons.map((json) => LocalStudent.fromJson(json)).toList();

      final progressSnapshot = widget.studentManager.addStudents(students);
      feedStream(progressRepository, progressSnapshot);
      setState(() {
        _files = null;
      });
    }
  }

  Widget uploadButton() {
    return _files != null
        ? Builder(builder: (BuildContext context) {
            return RaisedButton(
              onPressed: () => loadFiles(this.repo),
              child: Text("Load Files To DB"),
            );
          })
        : Container(
            alignment: AlignmentDirectional.center,
            child: Text(
              'Thank you, the students are being uploaded to the server in this moment',
              textAlign: TextAlign.center,
            ),
          );
  }

  Widget filesList() {
    return Builder(
        builder: (BuildContext context) => _loadingPath
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: const CircularProgressIndicator())
            : _files != null
                ? Container(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: Scrollbar(
                        child: ListView.separated(
                      itemCount: _files != null && _files.isNotEmpty
                          ? _files.length
                          : 1,
                      itemBuilder: (BuildContext context, int index) {
                        final String name = 'File $index: ' +
                            (_files.map((e) => e.path).toList()[index]);
                        final path = _files.toList()[index].toString();

                        return ListTile(
                          title: Text(
                            name,
                          ),
                          subtitle: Text(path),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(),
                    )),
                  )
                : Container());
  }

  Widget loadCsvButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
      child: RaisedButton(
        onPressed: () => _openFileExplorer(),
        child: Text("Load CSV"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Disposer(
      create: () => ProgressRepository(),
      builder: (context, repo) {
        this.repo = repo;
        return ProgressScaffold(
          repo: repo,
          body: buildBody(context),
        );
      },
    );
  }

  Widget _buildExpectedFormat() {
    return Text(
      [
        "Expecting a CSV format",
        "Each line contains the following fields:",
        "(leave a field empty if you don't",
        " want to specify a value at this time)",
        "",
        ...LocalStudent.getFields(),
      ].join("\n"),
    );
  }

  Widget buildBody(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(padding: const EdgeInsets.only(top: 50)),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 300.0),
                child: Text(
                  'Please load students table',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildExpectedFormat(),
              loadCsvButton(),
              uploadButton(),
              filesList(),
            ],
          ),
        ),
      ),
    );
  }
}
