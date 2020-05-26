import 'package:flutter/material.dart';

import '../filterable.dart';
import 'field_filter.dart';
import 'filterable_field.dart';

typedef FilterWidgetCreator = Widget Function(
    void Function(void Function() fn) setState);

class FiltersScaffold<Object, T, FilterInputType> extends StatefulWidget {
  final Filterable<T> filterable;
  final List<FilterableField> fields;

  final Map<int, FilterWidgetCreator> filterWidgets;

  FiltersScaffold({
    Key key,
    @required this.filterable,
    @required this.fields,
    @required this.filterWidgets,
  }) : super(key: key);

  @override
  _FiltersScaffoldState createState() => _FiltersScaffoldState();
}

class _FilterDataHolder {
  String filterName;
  dynamic filterValue;
}

class _FiltersScaffoldState extends State<FiltersScaffold> {
  void _showNewFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      child: Dialog(
        child: ListView.builder(
          itemCount: widget.fields.length,
          itemBuilder: (context, index) {
            final field = widget.fields[index];

            return ListTile(
              title: Text(field.field.name),
              onTap: () {
                // create a new filter
                _createFilter(field);

                // close the dialog
                Navigator.of(context).pop(true);
              },
            );
          },
        ),
      ),
    );
  }

  void _createFilter(FilterableField field) {
    final int filterId = widget.filterable.filterWith((obj, json) => true);
    final filterData = _FilterDataHolder();

    void onFilterChange(String filterName, dynamic filterValue) {
      filterData.filterName = filterName;
      filterData.filterValue = filterValue;
    }

    Widget filterWidgetCreator(void Function(void Function()) setState) {
      final fieldFilter = DisplayedFieldFilter(
        key: ValueKey(filterId),
        field: field,
        filterId: filterId,
        filterable: widget.filterable,
        showFieldName: true,
        showFilterChoice: true,
        initialFilter: filterData.filterName,
        initialValue: filterData.filterValue,
        onFilterChange: onFilterChange,
      );

      final fullWidget = Row(
        // we use unique key because in the future there might be other filters with the same filterId
        key: UniqueKey(),
        children: <Widget>[
          // the filter
          Expanded(
            child: fieldFilter,
          ),

          // the deletion button
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.filterable.deleteFilter(filterId);
              setState(() => widget.filterWidgets.remove(filterId));
            },
          ),
        ],
      );
      return fullWidget;
    }

    setState(() => widget.filterWidgets[filterId] = filterWidgetCreator);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: SingleChildScrollView(
          child: Column(
            children: widget.filterWidgets.values
                .map((widgetCreator) => widgetCreator(setState))
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewFilterDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
