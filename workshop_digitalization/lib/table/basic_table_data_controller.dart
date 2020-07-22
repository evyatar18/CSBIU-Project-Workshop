import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/table/table_data_controller.dart';

typedef Comparator SorterMaker(String fieldName, Type fieldType);

class BasicTableDataController<T> implements TableDataController<T> {
  ValueStream<List<T>> supplier;
  @override
  ValueStream<List<T>> get unfilteredValues => supplier;

  StreamSubscription _subscription;
  StreamSubscription get dataSubscription => _subscription;

  final Map<String, dynamic> Function(T) jsoner;

  int _currentFilter = 0;
  final _filters = <int, ObjectFilter<T>>{};

  String sortColumn;
  bool ascending = true;

  final SorterMaker sorter;

  BasicTableDataController({
    @required this.supplier,
    @required this.jsoner,
    this.sorter = _defaultTypeSorter,
  }) {
    _subscription = supplier.listen(_dataListener);
  }

  final _controller = ReplaySubject<TableData<T>>();

  void _dataListener(List<T> data) {
    if (data == null) {
      return;
    }

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

    if (objects.isNotEmpty && sortCol != null) {
      final comparator = sorter(sortCol, objects.first[1][sortCol].runtimeType);
      objects.sort((e1, e2) {
        return comparatorFactor * comparator(e1[1][sortCol], e2[1][sortCol]);
      });
    }

    final emittedObjects = objects.map((e) => e[0]).toList();
    final cols = data.length > 0 ? jsoner(data[0]).keys : <String>[];

    final emit = TableData<T>(
        cols.toList(), sortCol, asc, emittedObjects.cast<T>(), jsoner);
    _controller.add(emit);
  }

  @override
  Stream<TableData<T>> get data => _controller;

  void _onDataChange() async {
    _dataListener(supplier.value);
  }

  @override
  void orderBy(String columnName, bool ascending) {
    sortColumn = columnName;
    this.ascending = ascending;
    _onDataChange();
  }

  @override
  void deleteFilter(int id) {
    _filters.remove(id);
    _onDataChange();
  }

  @override
  int filterWith(ObjectFilter<T> filter) {
    int id = _currentFilter++;
    _filters[id] = filter;
    _onDataChange();
    return id;
  }

  @override
  void setFilter(int id, ObjectFilter<T> filter) {
    _filters[id] = filter;
    _onDataChange();
  }

  @override
  void clearFilters() {
    _filters.clear();
    _currentFilter = 0;
    _onDataChange();
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

final _defaultStringComparator = (x, y) => x.toString().compareTo(y.toString());

// the type is not used anymore
Comparator _defaultTypeSorter(String fieldName, Type _) {
  Comparator comp;

  // we cannot identify whether the type has the `compareTo` until runtime,
  // so we'll check it in the first comparison
  comp = (x, y) {
    int carefulComparator(x, y) {
      try {
        return x.compareTo(y);
      } on NoSuchMethodError {
        // this may happen if the first x, y were comparables
        // but the ones after were not (x and y could be subtypes of the real type)
        comp = _defaultStringComparator;
        return comp(x, y);
      }
    }

    comp = x is Comparable && y is Comparable
        ? carefulComparator
        : _defaultStringComparator;

    return comp(x, y);
  };

  return (x, y) => comp(x, y);
}
