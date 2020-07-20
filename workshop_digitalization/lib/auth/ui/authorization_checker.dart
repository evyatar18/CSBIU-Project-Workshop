import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/auth/auth.dart';
import 'package:workshop_digitalization/auth/ui/sign_out.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';

import 'auth_wrapper.dart';

class Authorizer extends StatelessWidget {
  final AuthBuilder builder;

  Authorizer({@required this.builder});

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseInstance>(context);
    final auth = firebase.authenticator;
    final firestore = firebase.firestore;

    return AuthWrapper(
      authenticator: auth,
      authBuilder: (context, user) {
        return StreamBuilder<DocumentSnapshot>(
          stream: firestore
              .collection("allowed")
              .document(user.firebaseUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return CompletelyCentered(
                children: <Widget>[
                  Text("Error on checking if authorized"),
                  Text(snapshot.error.toString()),
                ],
              );
            }

            if (!snapshot.hasData) {
              return LabeledCircularLoader(labels: ["Checking if authorized"]);
            }

            // make sure the document exists and has the admin flag on
            final userDoc = snapshot.data;
            if (!userDoc.exists || !userDoc.data["admin"]) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("You are not allowed to access data in this app."),
                    Text(
                      "Please sign in with an authorized account to continue.",
                    ),
                    SignOutButton(authenticator: auth),
                  ],
                ),
              );
            }

            return Provider.value(
              value: auth,
              builder: (context, _) => builder(context, user),
            );
          },
        );
      },
    );
  }
}
