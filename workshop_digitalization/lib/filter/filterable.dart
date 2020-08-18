import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// Defines a filter for a specific type `T` of an object
///
/// given an object and its json representation the filter decides whether to pass the object
/// or not
typedef bool ObjectFilter<T>(T obj, Map<String, dynamic> json);

/// Defines a field of an object
///
/// contains the name of the field, a getter for the field from the object
/// and a function which turns the field into a string
class ObjectField<Object, FieldType> {
  final String name;
  final FieldType Function(Object) getter;
  final String Function(FieldType) stringer;

  Type get type => FieldType;

  ObjectField({
    @required this.name,
    @required this.getter,
    this.stringer = _defaultStringer,
  });

  String asString(Object o) {
    return stringer(getter(o));
  }
}

// defines a simple string-turning function
String _defaultStringer(dynamic input) => input?.toString();

/// Defines a filterable collection
///
/// does not provide the values after filtering, just the functionality of filtering
abstract class Filterable<T> {

  /// Defines an object filter which accepts all values
  static final ObjectFilter acceptingAll = (obj, json) => true;

  /// a stream of all unfiltered values
  ValueStream<List<T>> get unfilteredValues;

  /// add a filter
  ///
  /// returns the id of the filter
  int filterWith(ObjectFilter<T> filter);

  /// changes a filter with the given id
  void setFilter(int id, ObjectFilter<T> filter);

  /// deletes a filter with the given id
  void deleteFilter(int id);

  /// clears all filters
  void clearFilters();
}