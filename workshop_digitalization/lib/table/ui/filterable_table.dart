import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/filter/filterable.dart';
import 'package:workshop_digitalization/filter/ui/field_filter.dart';
import 'package:workshop_digitalization/filter/ui/filterable_field.dart';
import 'package:workshop_digitalization/filter/ui/filters_scaffold.dart';
import 'package:workshop_digitalization/table/basic_table_data_controller.dart';
import 'package:workshop_digitalization/table/ui/updating_table.dart';

// we use stateful widget just because we need the dispose
class FilterableTable<Object> extends StatefulWidget {
  final String title;
  final Stream<List<Object>> objects;
  final List<String> shownFields;

  final List<FilterableField> filterableFields;
  final List<ObjectField> nonFilterFields;

  final void Function(BuildContext context, Object object) onClick;

  FilterableTable({
    this.title = "",
    @required this.objects,
    @required List<ObjectField<Object, String>> textFields,
    @required List<FilterableField> otherFilterables,
    this.nonFilterFields = const <ObjectField>[],
    this.shownFields = const <String>[],
    @required this.onClick,
  }) : filterableFields = []
          ..addAll(
            textFields.map((textField) =>
                createCastingFilterableField(createTextFilterable(textField))),
          )
          ..addAll(otherFilterables);

  @override
  _FilterableTableState<Object> createState() =>
      _FilterableTableState<Object>();
}

Map<String, dynamic> Function(dynamic) makeJsoner<T>(
    Iterable<ObjectField> fields) {
  return (obj) {
    final object = obj as T;
    final entries =
        fields.map((field) => MapEntry(field.name, field.asString(object)));
    return Map.fromEntries(entries);
  };
}

class _FilterableTableState<Object> extends State<FilterableTable> {
  ValueConnectableStream<List<Object>> _stream;
  StreamSubscription _subscription;

  BasicTableDataController<Object> _controller;

  final _filterWidgets = <int, FilterWidgetCreator>{};

  List<int> staticFiltersIds;
  List<FilterableField> staticFilters;

  @override
  void initState() {
    super.initState();
    _stream = ValueConnectableStream(widget.objects);
    _controller = BasicTableDataController(
      supplier: _stream,
      jsoner: makeJsoner<Object>([
        ...widget.filterableFields.map((e) => e.field),
        ...widget.nonFilterFields
      ]),
    );

    staticFilters = widget.filterableFields
        .where((filterableField) =>
            widget.shownFields.contains(filterableField.field.name))
        .toList();
    staticFiltersIds = List.generate(staticFilters.length,
        (index) => _controller.filterWith((obj, json) => true));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  _openFiltersWidget(BuildContext context, Filterable controller,
      Map<int, FilterWidgetCreator> filterWidgets) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FiltersScaffold(
          filterable: controller,
          fields: widget.filterableFields,
          filterWidgets: filterWidgets,
        ),
      ),
    );
  }

  Row _buildFilter(int index) {
    final field = staticFilters[index];
    final id = staticFiltersIds[index];

    return Row(
      children: <Widget>[
        Text("${field.field.name}"),
        SizedBox(width: 10),
        DisplayedFieldFilter(
          field: field,
          filterId: id,
          filterable: _controller,
          showFieldName: false,
          showFilterChoice: false,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // initialize subscription if needed
    _subscription ??= _stream.connect();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          ...List<Row>.generate(staticFilters.length, _buildFilter),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () =>
                _openFiltersWidget(context, _controller, _filterWidgets),
          ),
        ],
      ),
      body: UpdatingTable(
        controller: _controller,
        onClick: widget.onClick != null
            ? (object) => widget.onClick(context, object)
            : null,
      ),
    );
  }
}
