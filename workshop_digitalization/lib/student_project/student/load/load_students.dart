import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';
import 'package:workshop_digitalization/global/ui/exception_handler.dart';
import 'package:workshop_digitalization/platform/files.dart';
import 'package:workshop_digitalization/platform/init.dart';
import 'package:workshop_digitalization/progress/progress_repo.dart';
import 'package:workshop_digitalization/progress/ui/progress_displayer.dart';
import 'package:workshop_digitalization/student_project/student/load/csv_parser.dart';
import 'package:workshop_digitalization/student_project/student/local_student.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

class StudentLoaderScreen extends StatefulWidget {
  final StudentManager studentManager;

  StudentLoaderScreen(this.studentManager);

  @override
  _StudentLoaderScreenState createState() => _StudentLoaderScreenState();
}

class _StudentLoaderScreenState extends State<StudentLoaderScreen> {
  ProgressRepository _progress;
  final _unreadFiles = QueueList<PlatformFile>();

  @override
  void initState() {
    super.initState();
    _progress = ProgressRepository();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Student CSV")),
      body: ProgressScaffold(
        repo: _progress,
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: CompletelyCentered(
            children: [
              _buildExpectedFormat(),
              _buildChooseFiles(),
              SizedBox(height: 50),
              if (_unreadFiles.isNotEmpty)
                Expanded(child: _buildDisplayedFiles()),
            ],
          ),
        ),
      ),
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
        ...LocalStudent.fields,
      ].join("\n"),
    );
  }

  Widget _buildChooseFiles() {
    return RaisedButton(
      child: Text("Choose Files"),

      // open the choose files dialog, and add all files into the unread files list
      onPressed: () => currentPlatform.files.chooseFiles(["csv", "txt"]).then(
        (files) {
          if (files.isNotEmpty) {
            setState(() => _unreadFiles.addAll(files));
          }
        },
      ),
    );
  }

  Widget _buildDisplayedFiles() {
    return Builder(
      builder: (context) {
        return Column(
          children: [
            _buildUploadButton(context),
            Expanded(child: _buildFileList()),
          ],
        );
      },
    );
  }

  Widget _buildFileList() {
    return ListView.separated(
      itemCount: _unreadFiles.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(_unreadFiles[i].name),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => setState(() => _unreadFiles.removeAt(i)),
          ),
        );
      },
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        // remove all files from the queue, parse them and add to students
        while (_unreadFiles.isNotEmpty) {
          PlatformFile file;
          setState(() => file = _unreadFiles.removeFirst());

          final studentStream = csvToJson(file.data, LocalStudent.fields)
              .map((json) => LocalStudent.fromJson(json));

          final fileUploadTask = studentStream.toList().then((students) =>
              _progress.feed(widget.studentManager.addStudents(students)));

          handleExceptions(
            context,
            fileUploadTask,
            "Error while parsing student file: ${file.name}",
          );
        }
      },
      child: Text("Upload"),
    );
  }
}
