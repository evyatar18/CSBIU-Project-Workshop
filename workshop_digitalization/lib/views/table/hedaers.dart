import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:workshop_digitalization/models/tableHeaders.dart';

class JsonTableHeader extends StatelessWidget {
  String header;
  Function f;
  JsonTableHeader({this.header}) {
    final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
    header = header
        .split(beforeCapitalLetter)
        .map((i) => (i[0].toUpperCase() + i.substring(1) + ' '))
        .join();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
          border: Border.all(width: 0.5), color: Colors.grey[300]),
      child: FlatButton(
        child: Text(
          header,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              color: Colors.black87),
        ),
      ),
    );
  }
}
