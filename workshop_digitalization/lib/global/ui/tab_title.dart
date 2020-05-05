import 'package:flutter/material.dart';

class TabName extends StatelessWidget {
  final String title;
  TabName({@required this.title});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(title),
    );
  }
}