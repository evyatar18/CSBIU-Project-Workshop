import 'package:flutter/material.dart';

import '../filterable.dart';
import 'field_filter.dart';
import 'filterable_field.dart';

class FiltersScaffold<Object, T, FilterInputType> extends StatefulWidget {
  final Filterable<T> filterable;
  final List<FilterableField> fields;

  final _filterWidgets = Map<int, Widget>();

  FiltersScaffold({
    Key key,
    @required this.filterable,
    @required this.fields,
  }) : super(key: key) {
    print("created scaffold");
  }

  @override
  _FiltersScaffoldState createState() => _FiltersScaffoldState();
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
    int filterId = widget.filterable.filterWith((obj, json) => true);

    final fieldFilter = DisplayedFieldFilter(
      key: ValueKey(filterId),
      field: field,
      filterId: filterId,
      filterable: widget.filterable,
      showFieldName: true,
      showFilterChoice: true,
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
            widget._filterWidgets.remove(filterId);
          },
        ),
      ],
    );

    setState(() {
      widget._filterWidgets[filterId] = fullWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter"),
      ),
      body: Column(children: widget._filterWidgets.values.toList()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewFilterDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
