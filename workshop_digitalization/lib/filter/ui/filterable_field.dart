import 'package:flutter/material.dart';
import 'package:workshop_digitalization/filter/ui/filter_widget.dart';

import '../filterable.dart';
import '../filters.dart';

typedef Widget DisplayedFilterBuilder<FilterType, InputType>(
  Map<FilterType, String> values,
  FilterType initialValue,
  void Function(InputType) onChange,
);

class FilterableField<Object, T, FilterInputType> {
  final ObjectField<Object, T> field;
  final Map<String, FilterCreator<T, FilterInputType>> filterCreators;
  final DisplayedFilterBuilder<T, FilterInputType> filterBuilder;

  FilterableField({
    @required this.field,
    @required this.filterCreators,
    @required this.filterBuilder,
  });
}

FilterableField<Object, String, String> createTextFilterable<Object>(
    ObjectField<Object, String> field) {
  return FilterableField<Object, String, String>(
    field: field,
    filterCreators: textFilters,
    filterBuilder: textFilterBuilder,
  );
}

FilterableField<Object, T, T> createSelectionFilterable<Object, T>(
    ObjectField<Object, T> field) {
  final emptyChoice = null;

  final withEmptyChoice = Map.of(selectionFilters)
      .map<String, bool Function(dynamic) Function(dynamic)>(
          (key, value) => MapEntry(key, (filterValue) {
                if (filterValue == emptyChoice) {
                  return (val) => Filterable.acceptingAll(val, null);
                }

                return value(filterValue as T);
              }));

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
