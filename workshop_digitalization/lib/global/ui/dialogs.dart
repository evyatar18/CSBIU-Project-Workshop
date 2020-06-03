import 'dart:async';

import 'package:flutter/material.dart';

Future<void> showAlertDialog(BuildContext context, String title, String body) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    child: AlertDialog(
      title: Text(title),
      content: Text(body),
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

Future<bool> showAgreementDialog(BuildContext context, String title) {
  final retval = Completer<bool>();

  showDialog(
    context: context,
    barrierDismissible: false,
    child: AlertDialog(
      title: Text(title),
      actions: <Widget>[
        FlatButton(onPressed: () => retval.complete(true), child: Text("YES")),
        FlatButton(onPressed: () => retval.complete(false), child: Text("NO")),
      ],
    ),
  );

  return retval.future;
}
