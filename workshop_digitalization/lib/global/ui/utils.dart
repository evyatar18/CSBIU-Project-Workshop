import 'package:flutter/material.dart';

void showSnackbarMessage(BuildContext context, String message) {
  Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
}