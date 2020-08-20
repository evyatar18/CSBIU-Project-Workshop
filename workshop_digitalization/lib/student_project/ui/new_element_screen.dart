import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/global/identified_type.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/student_project/element_manager.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';

import 'element_form_creator.dart';

class NewElementScreen<T extends StringIdentified> extends StatelessWidget {
  final ElementManager<T> elementManager;
  final String elementName;
  final ElementForm<T> elementFormCreator;

  final _formBuilderKey = GlobalKey<FormBuilderState>();

  NewElementScreen({
    Key key,
    @required this.elementManager,
    @required String elementName,
    @required this.elementFormCreator,
  })  : this.elementName = elementName.toLowerCase(),
        super(key: key);

  Future<bool> _save(BuildContext context, T element) async {
    try {
      await elementManager.save(element);
    } catch (e) {
      await showErrorDialog(
        context,
        title: "Error while tried to save $elementName",
        error: e.toString(),
      );
      return false;
    }

    await showSuccessDialog(context,
        title: "Saved new $elementName successfully!");
    return true;
  }

  Future<bool> _delete(BuildContext context, T element) async {
    if (!await showAgreementDialog(
        context, "Are you sure you want to delete this new $elementName?")) {
      return false;
    }

    try {
      await elementManager.delete(element);
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
      title: "Deleted new $elementName successfully!",
    );
    return true;
  }

  Widget _buildElement(BuildContext context, T element) {
    return Column(
      children: <Widget>[
        elementFormCreator(
          element: element,
          readOnly: false,
          formBuilderKey: _formBuilderKey,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              child: Text("Save"),
              onPressed: () async {
                // set values on the element object
                _formBuilderKey.currentState.save();

                // save the element
                if (await _save(context, element)) {
                  Navigator.pop(context);
                }
              },
            ),
            RaisedButton(
              child: Text("Delete"),
              onPressed: () async {
                if (await _delete(context, element)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final elementFuture = elementManager.createEmpty();

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(capitalize('Create New $elementName')),
        ),
        body: SingleChildScrollView(
            child: FutureBuilder(
          future: elementFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LabeledCircularLoader(
                labels: ["Getting a new instance of $elementName"],
              );
            }

            if (snapshot.hasError) {
              void snapshotErrorReporter() async {
                await showErrorDialog(
                  context,
                  title: "Error while tried to create new $elementName:",
                  error: snapshot.error.toString(),
                );

                // exit from new element screen
                Navigator.pop(context);
              }

              snapshotErrorReporter();
            }

            final element = snapshot.data;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: _buildElement(context, element),
            );
          },
        )),
        resizeToAvoidBottomPadding: false,
      ),

      // using back button == deleting
      onWillPop: () async => await _delete(context, await elementFuture),
    );
  }
}
