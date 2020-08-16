import 'package:flutter/cupertino.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';

Future<void> handleExceptions(
  BuildContext context,
  Future operation,
  String errorTitle, {
  String successMessage,
}) async {
  try {
    await operation;

    if (successMessage != null)
      await showSuccessDialog(
        context,
        title: "Operation Successful",
        message: successMessage,
      );
  } catch (e, trace) {
    await showErrorDialog(context, title: errorTitle, error: "$e \n$trace");
  }
}
