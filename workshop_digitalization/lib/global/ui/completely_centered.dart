import 'package:flutter/material.dart';

class CompletelyCentered extends StatelessWidget {
  final List<Widget> children;

  CompletelyCentered({@required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
