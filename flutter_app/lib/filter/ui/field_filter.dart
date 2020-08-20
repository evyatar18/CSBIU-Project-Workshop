import 'package:flutter/material.dart';
import '../filterable.dart';
import 'filterable_field.dart';

/// This is a displayed field filter
/// it includes the functionality of removing this filter
/// and changing its type (ie. from a textual filter with `startsWith` to a textual filter with `endsWith`)
class DisplayedFieldFilter<Object, FilterType, InputType>
    extends StatefulWidget {
  /// the filterable collection
  final Filterable<Object> filterable;

  /// the filter id representing the backend filter
  final int filterId;

  /// the field this filter is used
  final FilterableField<Object, FilterType, InputType> field;

  /// Whether to show the field name next to the filter
  final bool showFieldName;

  /// whether to allow changing the type of filter
  final bool showFilterChoice;

  /// the initial filter type name
  final String initialFilter;

  /// the initial value of the filter
  final InputType initialValue;

  /// a function which runs when the filter is changed (when the type or value changes)
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
    _changeFilter(initialFilter);

    if (widget.initialValue != null) {
      _changeFilterValue(widget.initialValue);
    }
  }

  void _onChange() {
    if (widget.onFilterChange != null) {
      widget.onFilterChange(_currentFilter, _currentValue);
    }
  }

  /// Change the current filter input value
  void _changeFilterValue(InputType val) {
    // create a new filter based on the value
    final filter = widget.field.filterCreators[_currentFilter](val);

    // set the filter on the backend
    widget.filterable.setFilter(widget.filterId, (obj, json) {
      final field = widget.field.field.getter(obj);
      return filter(field);
    });

    // report change to the filter
    _currentValue = val;
    _onChange();
  }

  /// change the current filter type
  void _changeFilter(String filterName) {
    setState(() {
      // when changing filter, reset the filter(it accepts any object)
      widget.filterable.setFilter(widget.filterId, Filterable.acceptingAll);
      _currentFilter = filterName;
    });

    _onChange();
  }

  /// the dropdown item which shows a name of a filter
  /// `filterName` is the name of the filter to show
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

  /// build the dropdown button which shows the currently used filter
  /// and allows changing the current filter
  DropdownButton _buildFilterChoiceButton() {
    return DropdownButton<String>(
      items:
          widget.field.filterCreators.keys.map(_buildDropdownFilter).toList(),

      // when filter type changed
      onChanged: _changeFilter,
      value: _currentFilter,
    );
  }

  /// get the values for each field from the given list of objects
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

  /// the filter object which changes as new data is added to the unfiltered values
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
