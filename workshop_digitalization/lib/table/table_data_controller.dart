import 'dart:async';

import 'package:workshop_digitalization/filter/filterable.dart';

abstract class TableDataController<T> implements Filterable<T> {
  Stream<TableData<T>> get data;
  StreamSubscription get dataSubscription;

  void orderBy(String columnName, bool ascending);

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
