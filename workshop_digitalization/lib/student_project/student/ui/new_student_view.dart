import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/student_project/student/student.dart';

import 'student_form.dart';

class NewStudentScreen extends StatelessWidget {
  final StudentManager studentManager;
  final _formBuilderKey = GlobalKey<FormBuilderState>();

  NewStudentScreen({Key key, @required this.studentManager}) : super(key: key);

  Future<bool> _save(BuildContext context, Student student) async {
    try {
      await studentManager.save(student);
    } catch (e) {
      await showErrorDialog(
        context,
        title: "Error while tried to save student",
        error: e.toString(),
      );
      return false;
    }

    await showSuccessDialog(context, title: "Saved new student successfully!");
    return true;
  }

  Future<bool> _delete(BuildContext context, Student student) async {
    if (!await showAgreementDialog(
        context, "Are you sure you want to delete this new student?")) {
      return false;
    }

    try {
      await studentManager.delete(student);
    } catch (e) {
      await showErrorDialog(
        context,
        title: "Error while tried to delete:",
        error: e.toString(),
      );
      return false;
    }

    await showSuccessDialog(
      context,
      title: "Deleted new student successfully!",
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final studentFuture = studentManager.createEmpty();

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create New Student'),
        ),
        body: SingleChildScrollView(
            child: FutureBuilder(
          future: studentFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              void snapshotErrorReporter() async {
                await showErrorDialog(
                  context,
                  title: "Error while tried to create new student:",
                  error: snapshot.error.toString(),
                );
                Navigator.pop(context);
              }

              snapshotErrorReporter();
            }

            final student = snapshot.data;
            return Column(
              children: <Widget>[
                StudentForm(
                  student: student,
                  readOnly: false,
                  formBuilderKey: _formBuilderKey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("Save"),
                      onPressed: () async {
                        // set values on student object
                        _formBuilderKey.currentState.save();

                        // save the student object
                        if (await _save(context, student)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    RaisedButton(
                      child: Text("Delete"),
                      onPressed: () async {
                        if (await _delete(context, student)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                )
              ],
            );
          },
        )),
        resizeToAvoidBottomPadding: false,
      ),

      // using back button == deleting
      onWillPop: () async => await _delete(context, await studentFuture),
    );
  }
}
