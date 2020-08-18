import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:workshop_digitalization/auth/auth.dart';

import '../firebase_root.dart';
import '../active_root.dart';
import '../roots.dart';

/// All the settings which are relevant to a specific instance of firebase connection exist here
class FirebaseInstance {
  final FirebaseApp app;

  final Firestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  Roots _roots;

  Authenticator _authenticator;
  Authenticator get authenticator => _authenticator;

  Roots get roots => _roots;

  FirebaseInstance(this.app)
      : firestore = Firestore(app: app),
        storage = FirebaseStorage(app: app),
        auth = FirebaseAuth.fromApp(app) {
    _roots = Roots(firestore: firestore);
    _authenticator = Authenticator(auth);
  }

  Future<void> dispose() => roots.dispose();

  ActiveRoot _root;
  ActiveRoot get activeRoot => _root;

  Future<void> useRoot(FirebaseRoot root) {
    final tasks = [
      if (_root != null) _root.dispose(),
    ];

    _root = ActiveRoot(root, this);
    return Future.wait(tasks);
  }
}

Future<FirebaseInstance> initializeApp(FirebaseOptions opts) =>
    FirebaseApp.configure(name: opts.googleAppID, options: opts)
        .then((app) => FirebaseInstance(app));
