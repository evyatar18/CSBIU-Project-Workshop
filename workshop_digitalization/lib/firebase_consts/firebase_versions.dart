// This file takes care of the different firebase roots

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workshop_digitalization/firebase_consts/firebase_root.dart';
import 'roots.dart';

const String versionField = "versionName";

CollectionReference firestoreRootCollection;
FirebaseRoot currentRoot;

Future<FirebaseRoot> useRoot(FirebaseRoot root) async {
  if (!roots.listening) {
    await root.refreshValues();
  }
  return currentRoot = root;
}

Future<FirebaseRoot> useRootByName(String rootName) async {
  return await useRoot(await roots.getRoot(rootName));
}
