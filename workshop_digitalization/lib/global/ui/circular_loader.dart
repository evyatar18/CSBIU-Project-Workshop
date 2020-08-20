import 'package:flutter/material.dart';

import 'completely_centered.dart';

class LabeledCircularLoader extends StatelessWidget {
  final List<String> labels;
  final List<Widget> children;

  LabeledCircularLoader({
    this.labels = const [""],
    this.children = const [],
  })  : assert(labels != null),
        assert(children != null);

  @override
  Widget build(BuildContext context) {
    return CompletelyCentered(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        ...labels.map((label) => Text(label)),
        ...children
      ],
    );
  }
}
