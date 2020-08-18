import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A representation of a logged in user
class AuthenticatedUser {
  FirebaseUser firebaseUser;
  AuthenticatedUser(this.firebaseUser);
}

/// The service class which provides the authentication methods
class Authenticator {
  final FirebaseAuth _auth;
  final _googleSignIn = GoogleSignIn();

  Authenticator(this._auth);

  /// the logged in user stream, returns the user if they're logged in
  /// otherwise returns null
  Stream<AuthenticatedUser> get user =>
      _auth.onAuthStateChanged.map(_userFromFirebaseUser);

  /// creates an `AuthenticatedUser` instance from a `FirebaseUser` instance
  AuthenticatedUser _userFromFirebaseUser(FirebaseUser user) {
    return user == null ? null : AuthenticatedUser(user);
  }

  /// Sign out
  Future<void> signOut() => _auth.signOut();

  /// Register with email and password
  Future<AuthenticatedUser> register(String email, String password) async {
    try {
      final account = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthenticatedUser(account.user);
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  Future<AuthenticatedUser> login(String email, String password) async {
    try {
      final account = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await account.user.reload();

      return AuthenticatedUser(account.user);
    } catch (e) {
      rethrow;
    }
  }

  /// Send a password reset link to the given email
  Future<void> forgotten(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
