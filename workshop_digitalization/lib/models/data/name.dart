import 'package:flutter/foundation.dart';

class Name {
  final String first;
  final String last;

  Name({ @required this.first , @required this.last });

  @override
  String toString() {
    return "{ Name: $first, $last }";
  }
}