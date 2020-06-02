import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  Map<String, String> _paths;
  String _extension = 'csv';
  bool _loadingPath = false;
  FilesListState _state;
  Stream<ProgressSnapshot> progressSnapshot;

  //this widget open the file explorer for choose csv files
  Future<void> _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.custom,
          allowedExtensions: (_extension?.isNotEmpty ?? false)
              ? _extension?.replaceAll(' ', '')?.split(',')
              : null);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
    });
  }

  Future<void> loadFiles(ProgressRepository progressRepository) async {
    FileParser parser = CsvFileParser();
    List<Map<String, dynamic>> jsons = [];
    if (_paths != null) {
      var fields =LocalStudent.getFields();
      for (var path in _paths.values) {
        jsons = jsons..addAll(await parser.parse(path, fields));
      }
      List<Student> students = jsons
          .map((json) => LocalStudent.fromJson(json))
          .toList(); //= jsons..map((json)=>));

      final progressSnapshot = widget.studentManager.addStudents(students);
      feedStream(progressRepository, progressSnapshot);
      setState(() {
        _paths = null;
        _state = FilesListState.AFTER;
      });
    }
  }

  Widget uploadButton() {
    return _paths != null
        ? Builder(builder: (BuildContext context){
          return RaisedButton(
            onPressed: () => loadFiles(this.repo),
            child: Text("Load Files To DB"),
          );
        }) 
        : Container(
          alignment: AlignmentDirectional.center,
          child: Text('Thank you , the students uploadad to the server in this moments' , 
          textAlign: TextAlign.center,),
        );
  }

  Widget filesList() {
    return Builder(
        builder: (BuildContext context) => _loadingPath
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: const CircularProgressIndicator())
            : _paths != null
                ? Container(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: Scrollbar(
                        child: ListView.separated(
                      itemCount: _paths != null && _paths.isNotEmpty
                          ? _paths.length
                          : 1,
                      itemBuilder: (BuildContext context, int index) {
                        final String name =
                            'File $index: ' + (_paths.keys.toList()[index]);
                        final path = _paths.values.toList()[index].toString();

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
        return  ProgressScaffold(
            repo: repo,
            body: buildBody(context),
        );
      },
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
              loadCsvButton(),
              filesList(),
              uploadButton(),
            ],
          ),
        ),
      ),
    );
  }
}
