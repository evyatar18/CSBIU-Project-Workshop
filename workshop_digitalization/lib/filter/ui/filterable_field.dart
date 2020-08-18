import 'package:flutter/material.dart';
import 'package:workshop_digitalization/filter/ui/filter_widget.dart';

import '../filterable.dart';
import '../filters.dart';

/// builds a filter widget
///
/// `values` contains all the available values that can be filtered from
/// for example, if we have a filter for `color`, then values may contain `red`, `blue` and `green` (according to which
/// colors are in the data that can be filtered).
/// `values` is a map because we needed a quick way to attach the textual representation to the filter input type.
///
/// `initialValue` is the initial value of the filter
///
/// `onChange` is called by the filter widget when its input is changed
typedef Widget DisplayedFilterBuilder<FilterType, InputType>(
  Map<FilterType, String> values,
  FilterType initialValue,
  void Function(InputType) onChange,
);

/// a field of an object that can be filtered
class FilterableField<Object, T, FilterInputType> {
  /// the field itself
  final ObjectField<Object, T> field;

  /// a mapping between names of filters to their filter creators
  final Map<String, FilterCreator<T, FilterInputType>> filterCreators;

  /// a widget that displays the filters
  ///
  /// note: the same widget is used for all filters given
  /// for example, on a textual field this widget will be TextField
  final DisplayedFilterBuilder<T, FilterInputType> filterBuilder;

  FilterableField({
    @required this.field,
    @required this.filterCreators,
    @required this.filterBuilder,
  });
}

/// Creates a `FilterableField` for a textual field of a given object
FilterableField<Object, String, String> createTextFilterable<Object>(
    ObjectField<Object, String> field) {
  return FilterableField<Object, String, String>(
    field: field,
    filterCreators: textFilters,
    filterBuilder: textFilterBuilder,
  );
}

/// Creates a `FilterableField` for a selection-able field of a given object
FilterableField<Object, T, T> createSelectionFilterable<Object, T>(
    ObjectField<Object, T> field) {
  // this adds the `any` option for the selection filter
  final emptyChoice = null;
  final withEmptyChoice = Map.of(selectionFilters)
      .map<String, bool Function(dynamic) Function(dynamic)>(
    (key, value) => MapEntry(key, (filterValue) {
      if (filterValue == emptyChoice) {
        return (val) => Filterable.acceptingAll(val, null);
      }

      return value(filterValue as T);
    }),
  );

  return FilterableField<Object, T, T>(
    field: field,
    filterCreators: withEmptyChoice,
    filterBuilder: (values, initialValue, onChange) {
      values = Map.fromEntries([
        MapEntry(emptyChoice, "any"),
        if (values != null) ...values.entries
      ]);

      return selectionFilterBuilder(values, initialValue, onChange);
    },
  );
}

/// Casts a given `FilterableField` so that all its generics are `dynamic`
/// essentially, dropping all generics
FilterableField createCastingFilterableField<Object, T, FilterInputType>(
    FilterableField<Object, T, FilterInputType> field) {
  return FilterableField(
    field: ObjectField(
      name: field.field.name,
      getter: (obj) => field.field.getter(obj as Object),
      stringer: (val) => field.field.stringer(val as T),
    ),
    filterCreators: field.filterCreators.map(
      (key, value) => MapEntry(key, (x) {
        final func = value(x as FilterInputType);
        return (val) => func(val as T);
      }),
    ),
    filterBuilder: (values, initialValue, onChange) {
      return field.filterBuilder(
        values.cast<T, String>(),
        initialValue as T,
        onChange,
      );
    },
  );
}
