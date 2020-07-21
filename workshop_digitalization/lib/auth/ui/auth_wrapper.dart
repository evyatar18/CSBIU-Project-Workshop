import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workshop_digitalization/auth/auth.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/ui/change_db.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';
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
    return CompletelyCentered(children: [
      _buildSignInEmail(context),
      SizedBox(height: 10),
      Text("Or change a database:"),
      ChangeDBButton(),
    ]);
  }

  Function onErrorHandler(BuildContext context) {
    return (error) {
      showErrorDialog(
        context,
        title: "An error occurred:",
        error: error.toString(),
      );
    };
  }

  Widget _buildSignInEmail(BuildContext context) {
    String email = "", password = "";
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: <Widget>[
          Text("Sign in with email"),
          TextField(
            decoration: InputDecoration(labelText: "email"),
            onChanged: (value) => email = value,
          ),
          TextField(
            decoration: InputDecoration(labelText: "password"),
            onChanged: (value) => password = value,
            obscureText: true,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RaisedButton(
                child: Text("Login"),
                onPressed: () => authenticator
                    .login(email, password)
                    .catchError(onErrorHandler(context)),
              ),
              // SizedBox(width: 20),
              RaisedButton(
                child: Text("Register"),
                onPressed: () => authenticator
                    .register(email, password)
                    .catchError(onErrorHandler(context)),
              ),
              RaisedButton(
                child: Text("Forgotten Password"),
                onPressed: () {
                  return authenticator.forgotten(email).then(
                        (_) => showSuccessDialog(
                          context,
                          message: "Sent password reset email",
                        ),
                        onError: onErrorHandler(context),
                      );
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
