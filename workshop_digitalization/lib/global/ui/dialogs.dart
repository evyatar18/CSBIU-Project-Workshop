import 'dart:async';

import 'package:flutter/material.dart';

Future<void> showAlertDialog(BuildContext context, String title,
    [String body = ""]) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    child: AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("OK"),
        )
      ],
    ),
  );
}

Future<void> showErrorDialog(BuildContext context,
    {String title = "An error has occurred", String error = ""}) {
  return showAlertDialog(context, title, error);
}

Future<void> showSuccessDialog(BuildContext context,
    {String title = "Success!", String message = ""}) {
  return showAlertDialog(context, title, message);
}

Future<bool> showAgreementDialog(BuildContext context, String title,
    {bool barrierDismissible = false}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("NO"),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("YES"),
          ),
        ],
      );
    },
  );
}

Future<String> showTextInputDialog(BuildContext context, String title,
    {bool barrierDismissible = true}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      final textController = TextEditingController();

      return AlertDialog(
        content: TextField(
          decoration: InputDecoration(labelText: title),
          controller: textController,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text("CANCEL"),
          ),
          FlatButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: Text("SUBMIT"),
          ),
        ],
      );
    },
  );
}
