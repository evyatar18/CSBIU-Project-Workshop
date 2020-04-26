import 'package:flutter/material.dart';

class TabName extends StatelessWidget {
  String topic;
  TabName(this.topic);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(topic),
    );
  }
}