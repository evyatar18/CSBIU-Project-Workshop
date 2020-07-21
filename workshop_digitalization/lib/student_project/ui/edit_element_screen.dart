import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/global/identified_type.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/student_project/element_manager.dart';
import 'package:workshop_digitalization/student_project/ui/element_form_creator.dart';

class EditElementForm<T extends StringIdentified> extends StatefulWidget {
  final T element;
  final ElementManager<T> elementManager;
  final ElementForm<T> formCreator;
  final bool enableDeleting;

  EditElementForm({
    @required this.element,
    @required this.elementManager,
    @required this.formCreator,
    this.enableDeleting = true,
    Key key,
  }) : super(key: key);

  @override
  EditElementFormState<T> createState() => EditElementFormState<T>();
}

class EditElementFormState<T extends StringIdentified>
    extends State<EditElementForm<T>> {
  var _readOnly = true;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.all(18),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                // title: Text("Edit by clicking"),
                trailing: Wrap(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () async {
                        if (await canPop) {
                          _toggleEdit();
                        }
                      },
                      child: Icon(Icons.edit, color: color),
                    ),
                    if (widget.enableDeleting)
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _delete(context);
                          Navigator.pop(this.context);
                        },
                      ),
                  ],
                ),
              ),
              widget.formCreator(
                element: widget.element,
                readOnly: _readOnly,
                formBuilderKey: _fbKey,
                // initialValues: _initialValues,
              ),
            ],
          ),
        ),
        bottomNavigationBar: _readOnly
            ? null
            : WillPopScope(child: _saveSection(), onWillPop: () => canPop),
      ),
    );
  }

  Widget _saveSection() {
    return Container(
      child: ButtonBar(
        children: <Widget>[
          RaisedButton(
            child: Text("Submit"),
            onPressed: _onSubmit,
          ),
          MaterialButton(
            child: Text("Reset"),
            onPressed: () => setState(() => _fbKey.currentState.reset()),
          ),
        ],
      ),
    );
  }

  final _mapComparer = MapEquality<String, dynamic>().equals;
  Map<String, dynamic> get _latestValues => _fbKey.currentState.value;
  Map<String, dynamic> _valuesBeforeEdit = {};

  /// returns true if can pop
  Future<bool> get canPop =>
      // test if we're on readonly, or we're on edit but the values didnt change
        _readOnly
          ? Future.value(true)
          : showAgreementDialog(
              context, "Are you sure you want to discard the latest changes?");

  void _ensureValues() {
    final values = _latestValues;
    _fbKey.currentState.fields.forEach((key, value) {
      if (values.containsKey(key)) value.currentState.didChange(values[key]);
    });
  }

  void _onSubmit() {
    if (_fbKey.currentState.validate()) {
      setState(() {
        _fbKey.currentState.save();
        // _initialValues = _fbKey.currentState.value;
        _ensureValues();
      });
      widget.elementManager.save(widget.element).then(
        (value) => showSuccessDialog(context, title: "Save successful"),
        onError: (err) {
          showErrorDialog(
            context,
            title: "Error on save",
            error: err.toString(),
          );
        },
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _valuesBeforeEdit = _latestValues;

      // remove values from form if toggled off
      if (!_readOnly) {
        _fbKey.currentState.reset();
      }

      _ensureValues();

      _readOnly = !_readOnly;
    });
  }

  Future<void> _delete(BuildContext context) async {
    bool result = await showAgreementDialog(
        context, "Are you sure you want to delete this?");

    if (result == null || !result) {
      return;
    }

    try {
      await widget.elementManager.delete(widget.element);

      await showSuccessDialog(context, title: "Deletion successful.");
    } catch (e) {
      await showErrorDialog(
        context,
        title: "Deletion unsuccessful.",
        error: e.toString(),
      );
    }
  }
}
