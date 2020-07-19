import 'package:flutter/material.dart';

class LabeledCircularLoader extends StatelessWidget {
  final List<String> labels;

  LabeledCircularLoader({this.labels = const [""]});

  @override
  Widget build(BuildContext context) {
    return CompletelyCentered(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        ...labels.map((label) => Text(label))
      ],
    );
  }
}
