import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'firebase_root.dart';

class Roots {
  // the collection which includes all different roots
  final CollectionReference rootsCollection;

  // holds already created root objects
  var _cachedRoots = <String, FirebaseRoot>{};

  StreamSubscription _sub;
  bool get listening => _sub != null;

  final ReplaySubject<List<FirebaseRoot>> _roots;

  Roots({bool startListening = false, Firestore firestore})
      : assert(firestore != null),
        rootsCollection = firestore.collection("version"),
        _roots = ReplaySubject() {
    _roots.add([]);

    if (startListening) {
      listen();
    }

    _roots.stream.listen((value) {
      print("roots: ${value.map((e) => e.name).toList()}");
    });
  }

  void listenAndStopOld() {
    if (listening) {
      _sub?.cancel();
    }
    _sub = null;
    listen();
  }

  void listen() {
    if (!listening) {
      _sub = rootsCollection.snapshots().listen(
        _snapshotListener,
        onError: (error, stackTrace) {
          _roots.addError(error, stackTrace);
          _sub = null;
        },
        cancelOnError: true,
      );
    }
  }

  void _snapshotListener(QuerySnapshot snapshot) {
    print("received roots: ${snapshot.documents.length} roots");
    final roots = snapshot.documents
        .where((doc) => doc.exists)
        .map(_constructRoot)
        .toList();

    // calculate the new root entries
    final newRootEntries = Map.fromEntries(
      roots.map((e) => MapEntry(e.name, e)),
    );

    // dispose of old roots
    final availableRoots = roots.map((e) => e.reference.documentID);
    _cachedRoots.values.map((e) => e.reference.documentID).toSet()
      ..removeAll(availableRoots)
      ..forEach((element) => _cachedRoots[element]?.dispose());

    // set new cached roots
    _cachedRoots = newRootEntries;

    _roots.add(roots);
  }

  Future<void> stopListening() {
    var future = _sub?.cancel();
    _sub = null;
    return future.then((_) => _roots.add([]));
  }

  Stream<List<FirebaseRoot>> get rootStream => _roots.stream;

  FirebaseRoot _constructRoot(DocumentSnapshot snapshot) {
    final name = snapshot.data[FirebaseRoot.rootNameField];

    if (_cachedRoots.containsKey(name)) {
      return _cachedRoots[name]..updateData(snapshot.data);
    }

    final root = FirebaseRoot(snapshot.reference, vals: snapshot.data);
    _cachedRoots[root.name] = root;
    return root;
  }

  /// Gets a root from the firebase collection or creates it if it doesn't exist
  Future<FirebaseRoot> getRoot(String name) {
    if (_cachedRoots.containsKey(name)) {
      // return the root with refreshed values
      final root = _cachedRoots[name];
      return root.refreshValues().then((_) => root);
    }

    return _rootGetter(name);
  }

  /// Gets a root from the firebase collection or creates it if it doesn't exist
  Future<FirebaseRoot> _rootGetter(String name) async {
    final query = await rootsCollection
        .where(FirebaseRoot.rootNameField, isEqualTo: name)
        .getDocuments();

    DocumentSnapshot snapshot;

    if (query.documents.isNotEmpty) {
      snapshot = query.documents.first;
    } else {
      // create the root from zero if doesn't exist
      final ref = await rootsCollection.add({FirebaseRoot.rootNameField: name});
      snapshot = await ref.get();
    }

    return _constructRoot(snapshot);
  }

  Future<void> dispose() {
    final tasks = [
      Future<void>.sync(() => _cachedRoots.values.forEach((e) => e?.dispose())),
      _roots.close(),
      stopListening(),
    ];

    return Future.wait(tasks);
  }
}
