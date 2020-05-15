import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:workshop_digitalization/global/json/jsonable.dart';

import 'table_headers.dart';

// Decode your json string
class JsonDataTable<T extends Jsonable> extends StatefulWidget {
  final List<T> jsonableObjects;
  final void Function(T) onItemClick;

  JsonDataTable({
    this.jsonableObjects,
    this.onItemClick,
  });

  @override
  State<StatefulWidget> createState() {
    return JsonDataTableState();
  }
}

class JsonDataTableState extends State<JsonDataTable> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final String jsonSample = widget.jsonableObjects
        .map((s) => s.toJson())
        .map((j) => json.encode(j))
        .toList()
        .toString();
    var js = jsonDecode(jsonSample);
    return JsonTable(
      js,
      paginationRowCount: 25,
      tableHeaderBuilder: (String header) {
        return JsonTableHeader(header: header);
      },
      showColumnToggle: true,
      onRowSelect: (index, map) =>
          widget.onItemClick(widget.jsonableObjects[index]),

    );
  }
}
