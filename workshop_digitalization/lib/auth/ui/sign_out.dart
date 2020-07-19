import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';

import '../auth.dart';

class SignOutButton extends StatelessWidget {
  final Authenticator authenticator;

  SignOutButton({
    @required this.authenticator,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.red,
      onPressed: () async {
        try {
          await authenticator.signOut();
          print("logged out successfully");
        } catch (e) {
          showErrorDialog(
            context,
            title: "Error signing out",
            error: e.toString(),
          );
        }
      },
      child: Text(
        "Logout",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
