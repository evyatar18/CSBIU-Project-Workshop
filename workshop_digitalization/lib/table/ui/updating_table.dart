import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:json_table/json_table.dart';

import '../table_data_controller.dart';
import 'table_header.dart';

/// a table which updates its data according to the given data stream
class UpdatingTable<T> extends StatelessWidget {
  final TableDataController<T> controller;
  final void Function(T) onClick;
  final int paginationRowCount;

  /// construct an `UpdatingTable`
  ///
  /// `controller` is the input table data controller for this table
  ///
  /// `onClick` is activated whenever a cell inside a row is clicked, returning the object of that row
  ///
  /// `paginationRowCount` is the amount of rows to use in each page
  UpdatingTable({
    @required this.controller,
    this.onClick,
    this.paginationRowCount = 25,
  });

  /// builds the json table using the given parameters
  ///
  /// `objects` is the list of objects to use
  ///
  /// `jsoner` translates each object into a json
  ///
  /// `orderColumn` is the name of the column currently ordered by, may be null if no column is sorted by
  ///
  /// `ascending` is whether the order column is ordered in ascending order
  Widget _buildTable(
      List<dynamic> objects, Map<String, dynamic> Function(dynamic) jsoner,
      [String orderColumn, bool ascending = false]) {
    final List<Map<String, dynamic>> jsonObjects = objects.map(jsoner).toList();

    return JsonTable(
      jsonObjects,
      paginationRowCount: paginationRowCount,
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
      tableCellBuilder: (value) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        );
      },
      onRowSelect:
          onClick == null ? null : (index, jsonMap) => onClick(objects[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TableData<dynamic>>(
      stream: controller.data,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: SpinKitChasingDots(
                color: Theme.of(context).accentColor, size: 80.0),
          );
        }

        final tableData = snapshot.data;
        final objects = tableData.objects;

        if (objects.isEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              "No available data. Either no data in collection or all data was filtered.",
            ),
          );
        }

        return tableData.sorted
            ? _buildTable(objects, tableData.jsoner, tableData.sortColumn,
                tableData.ascending)
            : _buildTable(objects, tableData.jsoner);
      },
    );
  }
}
