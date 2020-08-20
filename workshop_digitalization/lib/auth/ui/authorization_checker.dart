import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/auth/auth.dart';
import 'package:workshop_digitalization/auth/ui/sign_out.dart';
import 'package:workshop_digitalization/dynamic_firebase/setup.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';

import 'auth_wrapper.dart';

/// `Authorizer` is the widget which makes sure the *logged in* user is authorized to use the app
/// it checks against the `allowed` collection(on firestore) to see if there is a document with the user UID as
/// its document id and makes sure it has the `admin` field set to `true`
class Authorizer extends StatelessWidget {
  final AuthBuilder builder;

  Authorizer({@required this.builder});

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseInstance>(context);
    final auth = firebase.authenticator;

    return AuthWrapper(
      authenticator: auth,
      authBuilder: (context, user) {
        return _RefreshingAuthorizer(user, builder);
      },
    );
  }
}

class _RefreshingAuthorizer extends StatefulWidget {
  final AuthenticatedUser user;
  final AuthBuilder builder;

  _RefreshingAuthorizer(this.user, this.builder);

  @override
  __RefreshingAuthorizerState createState() => __RefreshingAuthorizerState();
}

class __RefreshingAuthorizerState extends State<_RefreshingAuthorizer> {
  Stream<DocumentSnapshot> _getUserDocSnapshot(
      DocumentReference userDoc) async* {
    try {
      DocumentSnapshot snapshot;
      while ((snapshot = await userDoc.get()) == null) {
        await Future.delayed(Duration(seconds: 5));
      }

      yield snapshot;

      yield* userDoc.snapshots();
    } catch (e, stack) {
      print("Error on getting user document snapshots:\n$e\n$stack");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseInstance>(context);
    final auth = firebase.authenticator;
    final userDoc = firebase.firestore
        .collection("allowed")
        .document(widget.user.firebaseUser.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: _getUserDocSnapshot(userDoc),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CompletelyCentered(
            children: <Widget>[
              Text("Error on checking if authorized"),
              Text(snapshot.error.toString()),
              SignOutButton(authenticator: auth),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return LabeledCircularLoader(
            labels: ["Checking if authorized"],
            children: [SignOutButton(authenticator: auth)],
          );
        }

        // make sure the document exists and has the admin flag on
        final userDoc = snapshot.data;
        if (userDoc == null || !userDoc.exists || !userDoc.data["admin"]) {
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
          builder: (context, _) => widget.builder(context, widget.user),
        );
      },
    );
  }
}
