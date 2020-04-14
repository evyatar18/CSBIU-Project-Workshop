import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:workshop_digitalization/models/data/repository/batchDataRepository.dart';
import 'package:workshop_digitalization/models/data/repository/dataRepository.dart';

import 'models/data/fileParser.dart';
import 'models/data/repository/singleDataRepsitory.dart';
import 'models/data/student.dart';

void main() => runApp(new LoadScreen());

class LoadScreen extends StatefulWidget {
  @override
  _LoadScreenState createState() => new _LoadScreenState();
}

enum FilesListState { BEFROE, WHILE, AFTER }

class _LoadScreenState extends State<LoadScreen> {
  String _fileName;

  String _path;
  Map<String, String> _paths;
  String _extension = 'csv';
  bool _loadingPath = false;
  bool _multiPick = false;
  BatchDataRepository _repository = new FirebaseBatchDataRepository('students');
  FilesListState _state;

  @override
  void initState() {
    super.initState();
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      if (_multiPick) {
        _path = null;
        _paths = await FilePicker.getMultiFilePath(
            type: FileType.custom,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
      } else {
        _paths = null;
        _path = await FilePicker.getFilePath(
          type: FileType.any,
        );
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _path != null
          ? _path.split('/').last
          : _paths != null ? _paths.keys.toString() : '...';
    });
  }

  void loadFiles() async {
    FileParser parser = new CsvFileParser();
    List<Map<String, dynamic>> jsons;
    if (_path != null || _paths != null) {
      final bool isMultiPath = _paths != null && _paths.isNotEmpty;
      if (isMultiPath) {
        for (var path in _paths.values) {
          jsons = jsons..addAll(await parser.parse(path, Student.getFields()));
        }
      } else {
        jsons = await parser.parse(_path, Student.getFields());
      }

      for (var json in jsons) {
         _repository.add(DBStudent.fromJson(json));
      }
      
     
      _path = null;
      _paths = null;
      setState(() {
        _state = FilesListState.AFTER;
      });
      
      _repository.commit();
    }
  }

  Widget uploadButton() {
    return _path != null || _paths != null
        ? RaisedButton(
            onPressed: () => loadFiles(),
            child: new Text("Load Files To DB"),
          )
        : Container();
  }

  Widget filesList() {
    return new Builder(
      builder: (BuildContext context) => _loadingPath
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: const CircularProgressIndicator())
          : _path != null || _paths != null
              ? new Container(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: new Scrollbar(
                      child: new ListView.separated(
                    itemCount:
                        _paths != null && _paths.isNotEmpty ? _paths.length : 1,
                    itemBuilder: (BuildContext context, int index) {
                      final bool isMultiPath =
                          _paths != null && _paths.isNotEmpty;
                      final String name = 'File $index: ' +
                          (isMultiPath
                              ? _paths.keys.toList()[index]
                              : _fileName ?? '...');
                      final path = isMultiPath
                          ? _paths.values.toList()[index].toString()
                          : _path;

                      return new ListTile(
                        title: new Text(
                          name,
                        ),
                        subtitle: new Text(path),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        new Divider(),
                  )),
                )
              : new Container(
                  child: getFilesText(),
                ),
    );
  }

  Widget getFilesText() {
    if (_state == FilesListState.AFTER) return Text('Your Files Were Upload');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: new Align(
          alignment: Alignment.topCenter,
            child: new Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: new SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(padding: const EdgeInsets.only( top:50)),
                new ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 300.0),
                  child: new Text(
                    'Please load students table',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                new ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 200.0),
                  child: new SwitchListTile.adaptive(
                    title: new Text('Pick multiple files',
                        textAlign: TextAlign.right),
                    onChanged: (bool value) =>
                        setState(() => _multiPick = value),
                    value: _multiPick,
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: new RaisedButton(
                    onPressed: () => _openFileExplorer(),
                    child: new Text("Load CSV"),
                  ),
                ),
                filesList(),
                uploadButton(),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
