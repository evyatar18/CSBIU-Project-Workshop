import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticatedUser {
  FirebaseUser firebaseUser;
  AuthenticatedUser(this.firebaseUser);
}

class Authenticator {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Stream<AuthenticatedUser> get user =>
      _auth.onAuthStateChanged.map(_userFromFirebaseUser);

  AuthenticatedUser _userFromFirebaseUser(FirebaseUser user) {
    return user == null ? null : AuthenticatedUser(user);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<AuthenticatedUser> googleSignInPrompt() async {
    final googleUser = await _googleSignIn.signIn();

    // authentication process was terminated
    if (googleUser == null) {
      return null;
    }

    final auth = await googleUser.authentication;

    final credential = GoogleAuthProvider.getCredential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    // we can ignore other parameters of the AuthResult object
    // maybe need to check if an exception is thrown
    final firebaseUser = (await _auth.signInWithCredential(credential)).user;

    return AuthenticatedUser(firebaseUser);
  }
}
