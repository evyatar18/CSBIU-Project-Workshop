import 'package:flutter/material.dart';
import 'package:workshop_digitalization/auth/auth.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/ui/change_db.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';

typedef Widget AuthBuilder(BuildContext context, AuthenticatedUser user);

class AuthWrapper extends StatelessWidget {
  final AuthBuilder authBuilder;
  final Authenticator authenticator;

  const AuthWrapper({
    @required this.authBuilder,
    @required this.authenticator,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthenticatedUser>(
      stream: authenticator.user,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          showErrorDialog(
            context,
            title: "Error in Authentication Service",
            error: snapshot.error.toString(),
          );
          return Container();
        }

        final user = snapshot.data;

        return user == null
            ? _buildSignIn(context)
            : authBuilder(context, user);
      },
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Sign in with google"),
          RaisedButton(
            child: Text("Google Sign-In"),
            onPressed: () async {
              try {
                final user = await authenticator.googleSignInPrompt();

                if (user == null) {
                  showAlertDialog(context, "Did not select a user");
                }
              } catch (e) {
                showErrorDialog(
                  context,
                  title: "error signing in",
                  error: e.toString(),
                );

                print("auth_wrapper - error signing in: $e");
              }
            },
          ),
          SizedBox(height: 10),
          Text("Or change a database:"),
          ChangeDBButton(),
        ],
      ),
    );
  }
}
