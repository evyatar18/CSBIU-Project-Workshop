import 'package:flutter/material.dart';

class ExapndableItem {
  Widget inner;
  String headerValue;
  bool isExpanded;
  ExapndableItem({
    this.inner,
    this.headerValue,
    this.isExpanded = false,
  });
}