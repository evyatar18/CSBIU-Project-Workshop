import 'package:flutter/material.dart';

class BidirectionalScrollViewSingleChild extends StatelessWidget {
  Widget child;

  BidirectionalScrollViewSingleChild({@required this.child});

  @override
  Widget build(BuildContext context) {
    // Bid
    // return child;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}