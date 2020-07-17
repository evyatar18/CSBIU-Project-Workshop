import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'firebase_root.dart';

Roots roots;

void initRoots() => roots = Roots(startListening: true);

class Roots {
  // the collection which includes all different roots
  final CollectionReference rootsCollection;

  // holds already created root objects
  final _cachedRoots = <String, FirebaseRoot>{};

  StreamSubscription _sub;
  bool get listening => _sub != null;

  final BehaviorSubject<List<FirebaseRoot>> _roots;

  Roots({bool startListening = false})
      : rootsCollection = Firestore.instance.collection("version"),
        _roots = BehaviorSubject() {
    if (startListening) {
      listen();
    }
  }

  void listen() {
    if (!listening) {
      _sub = rootsCollection.snapshots().listen(_snapshotListener);
    }
  }

  void _snapshotListener(QuerySnapshot snapshot) {
    final roots = snapshot.documents
        .where((doc) => doc.exists)
        .map(_constructRoot)
        .toList();
    _roots.add(roots);
  }

  Future<void> stopListening() {
    var future = _sub?.cancel();
    _sub = null;
    return future;
  }

  ValueStream<List<FirebaseRoot>> get rootStream => _roots;
  List<FirebaseRoot> get roots => _roots.value;

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
}
