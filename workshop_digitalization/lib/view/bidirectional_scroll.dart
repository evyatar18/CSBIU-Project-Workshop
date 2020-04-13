import 'package:flutter/material.dart';

class BidirectionalScrollViewSingleChild extends StatelessWidget {
  Widget child;

  BidirectionalScrollViewSingleChild({@required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: child
      ),
    );
  }
}