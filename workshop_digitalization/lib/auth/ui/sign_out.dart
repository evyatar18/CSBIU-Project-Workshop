import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';

import '../auth.dart';

/// The red `Logout` button
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
          final firebase =
              Provider.of<FirebaseInstance>(context, listen: false);
          await firebase.roots.stopListening();

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
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
