import 'package:flutter/material.dart';

//widget for tab title
class TabTitle extends StatelessWidget {
  final String title;
  TabTitle({@required this.title});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(title),
    );
  }
}