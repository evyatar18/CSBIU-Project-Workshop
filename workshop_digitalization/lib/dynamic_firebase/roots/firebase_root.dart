import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

/// represents a root which can be used in the app
class FirebaseRoot extends ChangeNotifier {
  static const String rootNameField = "name";

  final DocumentReference _ref;

  var _vals = <String, dynamic>{};

  Map<String, dynamic> get _values => _vals;
  set _values(Map<String, dynamic> vals) {
    _vals = (vals = vals ?? {});

    if (!vals.containsKey(rootNameField)) {
      vals[rootNameField] = _ref.documentID;
    }

    notifyListeners();
  }

  /// create a root from a given document reference
  ///
  /// `vals` are going to be the values this root will hold (if available during creation)
  /// if not values will be supplied, they'll be quieried from firestore
  FirebaseRoot(this._ref, {Map<String, dynamic> vals}) {
    if (vals == null) {
      refreshValues();
    } else {
      _values = vals;
    }
  }

  DocumentReference get reference => _ref;

  String get name => _values[rootNameField];
  set name(String val) => this[rootNameField] = val;

  /// query new values from firestore
  Future<void> refreshValues() async {
    final snapshot = await _ref.get();
    _values = snapshot.data;
  }

  /// get a property of the root
  dynamic operator [](String property) => _values[property];

  /// set a property of the root on firebase
  void operator []=(String prop, dynamic value) =>
      _ref.updateData({prop: value});

  /// update the inner data (just changes the state of this object, doesn't set the property on the firebase)
  void updateData(Map<String, dynamic> data) {
    _values = data;
  }
}
