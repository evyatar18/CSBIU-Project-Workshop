import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final _beforeCapitalLetter = RegExp(r"(?=[A-Z])");

class JsonTableHeader extends StatelessWidget {
  final String header;
  final void Function() onClick;
  final bool isOrderedBy;
  final bool ascending;

  JsonTableHeader(
      {@required String header, this.onClick, this.isOrderedBy, this.ascending = false})
      : header = header
            .split(_beforeCapitalLetter)
            .map((i) => (i[0].toUpperCase() + i.substring(1) + ' '))
            .join();

  @override
  Widget build(BuildContext context) {
    final text = Expanded(
      child: Text(
        header,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              color: Colors.black87,
            ),
      ),
    );

    var symbol;

    if (isOrderedBy) {
      symbol =
          ascending ? Icon(Icons.arrow_drop_down) : Icon(Icons.arrow_drop_up);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
          border: Border.all(width: 0.5), color: Colors.grey[300]),
      child: FlatButton(
        onPressed: onClick,
        child: Row(
          children: <Widget>[
            text,
            if (symbol != null)
              symbol
          ],
        ),
      ),
    );
  }
}
