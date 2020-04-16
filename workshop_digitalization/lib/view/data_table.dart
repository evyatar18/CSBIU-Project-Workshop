import 'package:flutter/material.dart';

typedef void ColumnClickListener(
    BuildContext context, String column, bool ascending);
typedef void RowClickListener(
    BuildContext context, Map<String, dynamic> clickedRow);

typedef DataColumn _ColumnBuilder(String columnName);
typedef DataRow _RowBuilder(Map<String, dynamic> rowData);

class BasicDataTable extends StatelessWidget {
  final BasicDataTableListeners listeners;
  final BasicDataTableData tableData;

  const BasicDataTable(this.tableData, this.listeners);

  _ColumnBuilder _buildColumn(BuildContext context) {
    // returns a context-dependent function

    return (String name) {
      return DataColumn(
        label: Text(name),
        numeric: false,
        tooltip: "Sort by $name",
        onSort: (index, ascending) {
          listeners.columnClick
              .forEach((listener) => listener(context, name, ascending));
        },
      );
    };
  }

  List<DataColumn> _buildColumns(BuildContext context) =>
      tableData.columns.map(_buildColumn(context)).toList();

  _RowBuilder _buildRow(BuildContext context) {
    // returns a context-dependent function

    return (Map<String, dynamic> rowData) {
      // when tapping on this row
      final onRowTap = () =>
          listeners.rowClick.forEach((listener) => listener(context, rowData));

      // map each column to its corresponding cell on this row
      final cells = tableData.columns
          .map(
              (col) => DataCell(Text(rowData[col].toString()), onTap: onRowTap))
          .toList();

      return DataRow(cells: cells);
    };
  }

  List<DataRow> _buildRows(BuildContext context) =>
      tableData.data.map(_buildRow(context)).toList();

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: _buildColumns(context),
      rows: _buildRows(context),
      sortAscending: tableData.ascending,
      sortColumnIndex: tableData.columns.indexOf(tableData.sortColumn),
    );
  }
}

abstract class BasicDataTableListeners {
  List<ColumnClickListener> get columnClick;
  List<RowClickListener> get rowClick;
}

class BasicDataTableData {
  final List<String> columns;
  final String sortColumn;
  final bool ascending;

  final List<Map<String, dynamic>> data;

  BasicDataTableData(this.columns, this.sortColumn, this.ascending, this.data);
}
