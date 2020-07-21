import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase_connection_bloc.dart';

class ChangeDBButton extends StatelessWidget {
  final Color buttonColor;
  final Color textColor;

  ChangeDBButton({
    this.buttonColor = Colors.yellow,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseConnectionBloc>(context);
    return RaisedButton(
      color: this.buttonColor,
      child: Text(
        "Change Database",
        style: TextStyle(color: textColor),
      ),
      onPressed: firebase.clearInstance,
    );
  }
}
