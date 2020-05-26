import 'package:flutter/material.dart';
import '../filterable.dart';
import 'filterable_field.dart';

class DisplayedFieldFilter<Object, FilterType, InputType>
    extends StatefulWidget {
  final Filterable<Object> filterable;
  final int filterId;

  final FilterableField<Object, FilterType, InputType> field;

  final bool showFieldName;
  final bool showFilterChoice;

  final String initialFilter;
  final InputType initialValue;

  final void Function(String filterName, InputType value) onFilterChange;

  DisplayedFieldFilter({
    Key key,
    @required this.filterable,
    @required this.field,
    @required this.filterId,
    this.showFieldName = true,
    this.showFilterChoice = true,
    this.initialFilter,
    this.initialValue,
    this.onFilterChange,
  }) : super(key: key);

  @override
  _DisplayedFieldFilterState createState() =>
      _DisplayedFieldFilterState<Object, FilterType, InputType>();
}

class _DisplayedFieldFilterState<Object, FilterType, InputType>
    extends State<DisplayedFieldFilter> {
  String _currentFilter;
  InputType _currentValue;

  @override
  void initState() {
    super.initState();

    final initialFilter =
        widget.initialFilter ?? widget.field.filterCreators.keys.first;
    _changeFilter(initialFilter, initialValue: widget.initialValue);
  }

  void _onChange() {
    if (widget.onFilterChange != null) {
      widget.onFilterChange(_currentFilter, _currentValue);
    }
  }

  void _changeFilterValue(InputType val) {
    final filter = widget.field.filterCreators[_currentFilter](val);
    widget.filterable.setFilter(widget.filterId, (obj, json) {
      final field = widget.field.field.getter(obj);
      return filter(field);
    });

    _currentValue = val;
    _onChange();
  }

  void _changeFilter(String filterName, {InputType initialValue}) {
    setState(() {
      // when changing filter, reset the filter(it accepts any object)
      widget.filterable.setFilter(widget.filterId, (obj, json) => true);
      _currentValue = initialValue;
      _currentFilter = filterName;
    });

    _onChange();
  }

  DropdownMenuItem<String> _buildDropdownFilter(String filterName) {
    return DropdownMenuItem<String>(
      child: Padding(
        // uses golden ratio (1.6180327868852)
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(filterName),
      ),
      value: filterName,
    );
  }

  DropdownButton _buildFilterChoiceButton() {
    return DropdownButton<String>(
      items:
          widget.field.filterCreators.keys.map(_buildDropdownFilter).toList(),

      // when filter type changed
      onChanged: _changeFilter,
      value: _currentFilter,
    );
  }

  Map<FilterType, String> _getFieldValues(List<dynamic> objects) {
    if (objects == null) {
      return Map.fromEntries(<MapEntry<FilterType, String>>[]);
    }
    final entries = objects
        .map(widget.field.field.getter)
        .toSet()
        .map((val) => MapEntry(val, widget.field.field.stringer(val)));
    return Map.fromEntries(entries);
  }

  Widget _buildFilterWidget() {
    final source = widget.filterable.unfilteredValues;
    return StreamBuilder<Map<FilterType, String>>(
      initialData: _getFieldValues(source.value),
      stream: source.map(_getFieldValues),
      builder: (context, snapshot) {
        return widget.field.filterBuilder(
          snapshot.data,
          _currentValue,
          _changeFilterValue,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (widget.showFieldName) Text(widget.field.field.name),
            Row(
              children: <Widget>[
                if (widget.showFilterChoice) _buildFilterChoiceButton(),
              ],
            )
          ],
        ),
        _buildFilterWidget()
      ],
    );
  }
}
