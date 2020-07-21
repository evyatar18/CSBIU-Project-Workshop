import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db_data.dart';

class ChangeDBButton extends StatelessWidget {
  final Color buttonColor;

  ChangeDBButton({
    this.buttonColor = Colors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseConnectionBloc>(context);
    return RaisedButton(
      color: this.buttonColor,
      child: Text("Change Database"),
      onPressed: firebase.clearInstance,
    );
  }
}
