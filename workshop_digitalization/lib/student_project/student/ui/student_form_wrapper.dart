import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'student_form.dart';
import '../student.dart';

class StudentDetailsForm extends StatefulWidget {
  final Student student;
  final StudentManager studentManager;

  StudentDetailsForm({
    @required this.student,
    @required this.studentManager
  }) : assert(student != null);

  @override
  _StudentDetailsFormState createState() => _StudentDetailsFormState();
}

class _StudentDetailsFormState extends State<StudentDetailsForm> {
  var _readOnly = true;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  Widget saveSection() {
    return _readOnly == false
        ? Container(
            child: ButtonBar(
              children: <Widget>[
                RaisedButton(
                  child: Text("Submit"),
                  onPressed: _onSubmit,
                ),
                MaterialButton(
                    child: Text("Reset"),
                    onPressed: () =>
                        setState(() => _fbKey.currentState.reset())),
              ],
            ),
          )
        : Container();
  }

  void _onSubmit() {
    if (_fbKey.currentState.validate()) {
      setState(() => _fbKey.currentState.save());
      widget.studentManager.save(widget.student);
    }
  }

  void _toggleEdit() {
    setState(() {
      // remove values from form if toggled off
      if (!_readOnly) {
        _fbKey.currentState.reset();
      }

      _readOnly = !_readOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text("Edit by clicking"),
              trailing: FlatButton(
                onPressed: _toggleEdit,
                child: Icon(Icons.edit, color: color),
              ),
            ),
            StudentForm(
              student: widget.student,
              canRead: _readOnly,
              formBuilderKey: _fbKey,
            ),
            saveSection(),
          ],
        ),
      ),
    );
  }
}
