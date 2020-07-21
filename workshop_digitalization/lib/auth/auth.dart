import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticatedUser {
  FirebaseUser firebaseUser;
  AuthenticatedUser(this.firebaseUser);
}

class Authenticator {
  final FirebaseAuth _auth;
  final _googleSignIn = GoogleSignIn();

  Authenticator(this._auth);

  Stream<AuthenticatedUser> get user =>
      _auth.onAuthStateChanged.map(_userFromFirebaseUser);

  AuthenticatedUser _userFromFirebaseUser(FirebaseUser user) {
    return user == null ? null : AuthenticatedUser(user);
  }

  Future<void> signOut() {
    return Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  Future<AuthenticatedUser> register(String email, String password) async {
    try {
      final account = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return AuthenticatedUser(account.user);
    }
    catch (e) {
      rethrow;
    }
  }

  Future<AuthenticatedUser> login(String email, String password) async {
    try {
      final account = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthenticatedUser(account.user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotten(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthenticatedUser> googleSignInPrompt() async {
    try {
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

      // sign in but with 5 second timeout
      final signinWithTimeout = await Future.any([
        _auth.signInWithCredential(credential),
        Future<AuthResult>.delayed(
          Duration(seconds: 5),
          () => throw "Google sign in timed out(5 seconds)",
        ),
      ]);

      // we can ignore other parameters of the AuthResult object
      // maybe need to check if an exception is thrown
      final firebaseUser = signinWithTimeout.user;

      return AuthenticatedUser(firebaseUser);
    } catch (e) {
      rethrow;
    }
  }
}
