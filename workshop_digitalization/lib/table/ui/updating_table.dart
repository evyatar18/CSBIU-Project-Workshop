import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:json_table/json_table.dart';
import 'package:workshop_digitalization/global/json/jsonable.dart';

import '../table_data_controller.dart';
import 'table_headers.dart';

class _JsonableType<T> implements Jsonable {
  final T object;
  final Map<String, dynamic> Function(T) jsoner;

  _JsonableType(this.object, this.jsoner);

  @override
  Map<String, dynamic> toJson() => jsoner(object);
}

class UpdatingTable<T> extends StatelessWidget {
  final TableDataController<T> controller;
  final void Function(T) onClick;

  UpdatingTable({@required this.controller, this.onClick});

  Widget _buildTable(List<_JsonableType<T>> jsons,
      [String orderColumn, bool ascending = false]) {
    final String jsonSample = jsons
        .map((s) => s.toJson())
        .map((j) => json.encode(j))
        .toList()
        .toString();
    var js = jsonDecode(jsonSample);
    return JsonTable(
      js,
      paginationRowCount: 25,
      tableHeaderBuilder: (String header) {
        bool isOrderedBy = orderColumn != null && header == orderColumn;
        return JsonTableHeader(
          header: header,
          isOrderedBy: isOrderedBy,
          ascending: ascending,
          onClick: () {
            controller.orderBy(header, isOrderedBy ? !ascending : true);
          },
        );
      },
      showColumnToggle: true,
      onRowSelect:
          onClick == null ? null : (index, map) => onClick(jsons[index].object),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(controller.data.value);
    return StreamBuilder<TableData<dynamic>>(
      initialData: controller.data.value,
      stream: controller.data,
      builder: (context, snapshot) {
        print("data: ${(snapshot.data == null)}");
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: SpinKitChasingDots(
                color: Theme.of(context).accentColor, size: 80.0),
          );
        }

        final tableData = snapshot.data;
        final jsonables = tableData.objects
            .map((e) => _JsonableType<T>(e, snapshot.data.jsoner))
            .toList();

        return tableData.sorted
            ? _buildTable(jsonables, tableData.sortColumn, tableData.ascending)
            : _buildTable(jsonables);
      },
    );
  }
}
