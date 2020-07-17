import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FirebaseRoot extends ChangeNotifier {
  static const String rootNameField = "name";

  final DocumentReference _ref;

  var _vals = <String, dynamic>{};

  Map<String, dynamic> get _values => _vals;
  set _values(Map<String, dynamic> vals) {
    _vals = vals;

    if (!vals.containsKey(rootNameField)) {
      vals[rootNameField] = _ref.documentID;
    }

    notifyListeners();
  }

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

  Future<void> refreshValues() async {
    final snapshot = await _ref.get();
    _values = snapshot.data;
  }

  dynamic operator [](String property) => _values[property];

  void operator []=(String prop, dynamic value) =>
      _ref.updateData({prop: value});

  void updateData(Map<String, dynamic> data) {
    _values = data;
  }
}
