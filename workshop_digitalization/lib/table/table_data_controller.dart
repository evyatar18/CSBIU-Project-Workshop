import 'dart:async';

import 'package:workshop_digitalization/filter/filterable.dart';

/// controls the data in a table
abstract class TableDataController<T> implements Filterable<T> {
  /// updates when there is a new data representation
  Stream<TableData<T>> get data;

  /// sorts by a specific column
  ///
  /// `columnName` the name of the column
  /// `ascending` whether the sorting is ascending or descending
  void orderBy(String columnName, bool ascending);

  /// disposes resources
  Future<void> dispose();
}

/// a data snapshot of the table
class TableData<T> {
  final List<String> columns;

  final String sortColumn;
  final bool ascending;

  bool get sorted => sortColumn != null;

  final List<T> objects;
  final Map<String, dynamic> Function(T) jsoner;

  TableData(
    this.columns,
    this.sortColumn,
    this.ascending,
    this.objects,
    this.jsoner,
  );
}
