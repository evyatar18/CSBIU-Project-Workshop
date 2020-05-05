import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:workshop_digitalization/global/json/jsonable.dart';
import 'package:workshop_digitalization/global/json/jsonable_details.dart';

import 'table_headers.dart';

// Decode your json string
class JsonDataTable extends StatefulWidget {
  List<Jsonable> jsonableObjects;
  JsonableDetailsFactory factory;
  JsonDataTable({this.jsonableObjects, this.factory});

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
      onRowSelect: (index, map) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                widget.factory.create(widget.jsonableObjects[index]),
          ),
        );
      },
    );
  }
}
