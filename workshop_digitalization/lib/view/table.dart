import 'package:flutter/material.dart';

typedef void ColumnClickListener(
    BasicDataTable instance, String column, bool ascending);
typedef void RowClickListener(
    BasicDataTable instance, Map<String, dynamic> clickedRow);

class BasicDataTable extends StatelessWidget {
  final BasicDataTableListeners listeners;
  final BasicDataTableData tableData;

  const BasicDataTable(this.tableData, this.listeners);

  List<DataColumn> _buildColumns() {
    return tableData.columns.map((name) => DataColumn(
        label: Text(name),
        numeric: false,
        tooltip: "Sort by $name",
        onSort: (index, ascending) {
          listeners.columnClick
              .forEach((listener) => listener(this, name, ascending));
        }));
  }

  List<DataRow> _buildRows() {
    return tableData.data.map((row) {
      // when tapping on this row
      final onRowTap =
          () => listeners.rowClick.forEach((listener) => listener(this, row));
      return DataRow(
          cells: tableData.columns.map((col) => DataCell(
                Text(row[col]),
                onTap: onRowTap,
              )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: _buildColumns(),
      rows: _buildRows(),
      sortAscending: tableData.ascending,
      sortColumnIndex: tableData.columns.indexOf(tableData.sortColumn),
    );
  }
}

class BasicDataTableListeners {
  final columnClick = <ColumnClickListener>[];
  final rowClick = <RowClickListener>[];

  void addColumnClickListener(ColumnClickListener ccs) => columnClick.add(ccs);
  void removeColumnClickListener(ColumnClickListener ccs) =>
      columnClick.remove(ccs);

  void addRowClickListener(RowClickListener rcs) => rowClick.add(rcs);
  void removeRowClickListener(RowClickListener rcs) => rowClick.remove(rcs);
}

class BasicDataTableData {
  final List<String> columns;
  final String sortColumn;
  final bool ascending;

  final List<Map<String, dynamic>> data;

  BasicDataTableData(this.columns, this.sortColumn, this.ascending, this.data);
}
