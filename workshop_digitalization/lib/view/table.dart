import 'package:flutter/material.dart';

typedef void ColumnClickListener(
    BasicDataTable instance, String column, bool ascending);
typedef void RowClickListener(
    BasicDataTable instance, Map<String, dynamic> clickedRow);

class BasicDataTable extends StatelessWidget {
  final List<String> _columns;
  final String _sortColumn;
  final bool _ascending;

  final List<Map<String, dynamic>> _data;

  final List<ColumnClickListener> _columnClickListeners;
  final List<RowClickListener> _rowClickListeners;

  const BasicDataTable(this._columns, this._sortColumn, this._ascending,
      this._data, this._columnClickListeners, this._rowClickListeners);

  List<DataColumn> _buildColumns() {
    return _columns.map((name) => DataColumn(
        label: Text(name),
        numeric: false,
        tooltip: "Sort by $name",
        onSort: (index, ascending) {
          _columnClickListeners
              .forEach((listener) => listener(this, name, ascending));
        }));
  }

  List<DataRow> _buildRows() {
    return _data.map((row) {
      // when tapping on this row
      final onRowTap =
          () => _rowClickListeners.forEach((listener) => listener(this, row));
      return DataRow(
          cells: _columns.map((col) => DataCell(
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
      sortAscending: _ascending,
      sortColumnIndex: _columns.indexOf(_sortColumn),
    );
  }
}
