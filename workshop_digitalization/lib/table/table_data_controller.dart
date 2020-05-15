import 'dart:async';

import 'package:rxdart/rxdart.dart';

typedef bool TableFilter<T>(T obj, Map<String, dynamic> json);

abstract class TableDataController<T> {
  ValueStream<TableData<T>> get data;
  StreamSubscription get dataSubscription;

  void orderBy(String columnName, bool ascending);

  int filterWith(TableFilter<T> filter);
  void setFilter(int id, TableFilter<T> filter);
  void deleteFilter(int id);
  void clearFilters();

  Future<void> dispose();
}

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
