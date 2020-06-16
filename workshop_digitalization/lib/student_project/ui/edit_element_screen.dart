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
  });

  @override
  _EditElementFormState<T> createState() => _EditElementFormState<T>();
}

class _EditElementFormState<T extends StringIdentified>
    extends State<EditElementForm<T>> {
  var _readOnly = true;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              // title: Text("Edit by clicking"),
              trailing: Wrap(
                children: <Widget>[
                  FlatButton(
                    onPressed: _toggleEdit,
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
            ),
            if (!_readOnly) _saveSection(),
          ],
        ),
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

  void _onSubmit() {
    if (_fbKey.currentState.validate()) {
      setState(() => _fbKey.currentState.save());
      widget.elementManager.save(widget.element).then(
        (value) => showSuccessDialog(context, title: "Save successful"),
        onError: (err) {
          showErrorDialog(context,
              title: "Error on save", error: err.toString());
        },
      );
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
