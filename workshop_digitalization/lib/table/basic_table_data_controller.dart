import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/table/table_data_controller.dart';

class BasicTableDataController<T> implements TableDataController<T> {
  StreamSubscription _subscription;
  StreamSubscription get dataSubscription => _subscription;

  final Map<String, dynamic> Function(T) jsoner;

  int _currentFilter = 0;
  final _filters = <int, TableFilter<T>>{};

  String sortColumn;
  bool ascending;

  BasicTableDataController({
    @required ValueStream<List<T>> supplier,
    @required this.jsoner,
  }) {
    _subscription = supplier.listen(_dataListener);
  }

  final _controller = BehaviorSubject<TableData<T>>();

  void _dataListener(List<T> data) {
    final sortCol = sortColumn;
    final asc = ascending;
    final comparatorFactor = asc ? 1 : -1;

    // keep object and its json, and filter them
    List<List> objects = data
        .map((e) => [e, jsoner(e)])
        .where(
          (lst) => _filters.values.every((filter) => filter(lst[0], lst[1])),
        )
        .toList();

    objects.sort((e1, e2) {
      return comparatorFactor *
          e1[1][sortCol].toString().compareTo(e2[1][sortCol].toString());
    });

    final emittedObjects = objects.map((e) => e[0]).toList();
    final cols = data.length > 0 ? jsoner(data[0]).keys : <String>[];

    final emit = TableData<T>(cols, sortCol, asc, emittedObjects, jsoner);
    _controller.add(emit);
  }

  @override
  ValueStream<TableData<T>> get data => _controller;

  @override
  void orderBy(String columnName, bool ascending) {
    sortColumn = columnName;
    this.ascending = ascending;
  }

  @override
  void deleteFilter(int id) {
    _filters.remove(id);
  }

  @override
  int filterWith(TableFilter<T> filter) {
    int id = _currentFilter++;
    _filters[id] = filter;
    return id;
  }

  @override
  void setFilter(int id, TableFilter<T> filter) {
    _filters[id] = filter;
  }

  @override
  void clearFilters() {
    _filters.clear();
    _currentFilter = 0;
  }

  @override
  Future<void> dispose() async {
    try {
      await _subscription.cancel();
    } catch (e) {
      print("$BasicTableDataController: $e");
    }

    try {
      await _controller.close();
    } catch (e) {
      print("$BasicTableDataController: $e");
    }
  }
}
