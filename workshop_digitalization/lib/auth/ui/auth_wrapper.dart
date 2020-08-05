import 'package:flutter/material.dart';
import 'package:workshop_digitalization/auth/auth.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/ui/change_db.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/settings/settings.dart';

typedef Widget AuthBuilder(BuildContext context, AuthenticatedUser user);

class AuthWrapper extends StatefulWidget {
  final AuthBuilder authBuilder;
  final Authenticator authenticator;

  const AuthWrapper({
    @required this.authBuilder,
    @required this.authenticator,
    Key key,
  }) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthBuilder get authBuilder => widget.authBuilder;
  Authenticator get authenticator => widget.authenticator;

  TextEditingController _email, _password;

  @override
  void initState() {
    super.initState();

    _email = TextEditingController(text: MyAppSettings.email);
    _password = TextEditingController(text: MyAppSettings.password);
  }

  @override
  void dispose() {
    super.dispose();

    _email.dispose();
    _password.dispose();
  }

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

  bool get _savePassword => MyAppSettings.savingPassword;
  void _changeSavePassword(bool b) {
    setState(() {
      MyAppSettings.savingPassword = b;
    });
  }

  void _saveDetails([bool withPassword]) {
    // use the `_savePassword getter` to infer the value of `withPassword`
    if (withPassword == null) {
      withPassword = _savePassword;
    }

    MyAppSettings.email = email;
    // save blank password if `withPassword` is false (to clear old password)
    _password.text =
        MyAppSettings.password = withPassword ? _password.text : "";
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

  String get email => _email.text.trim();
  String get password => _password.text;

  Widget _buildSignInEmail(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: <Widget>[
          Text("Sign in with email"),
          TextField(
            decoration: InputDecoration(labelText: "email"),
            controller: _email,
          ),
          TextField(
            decoration: InputDecoration(labelText: "password"),
            controller: _password,
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

                    // on successful login, save details
                    .then((_) => _saveDetails())
                    .catchError(onErrorHandler(context)),
              ),
              // SizedBox(width: 20),
              RaisedButton(
                child: Text("Register"),
                onPressed: () => authenticator
                    .register(email, password)
                    // on successful registration, save details
                    .then((_) => _saveDetails())

                    // we want the user to appear on the console
                    // and only after they are authorized may then sign in
                    .then((value) => authenticator.signOut())
                    .then(
                      (value) => showSuccessDialog(
                        context,
                        message: "Registered successfully,"
                            "login after confirmed on firebase",
                      ),
                    )

                    // return `false` so this error is unhandled
                    // and the other callbacks are not called
                    .catchError(onErrorHandler(context)),
              ),
              RaisedButton(
                child: Text("Forgotten Password"),
                onPressed: () {
                  authenticator
                      .forgotten(email)
                      .then((_) => showSuccessDialog(context,
                          message: "Sent password reset email"))
                      .catchError(onErrorHandler(context));
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              Switch(
                onChanged: _changeSavePassword,
                value: _savePassword,
              ),
              Text(
                "Save password on device?\n (saving in plaintext, insecure)",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
