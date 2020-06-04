import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

typedef bool ObjectFilter<T>(T obj, Map<String, dynamic> json);

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

String _defaultStringer(dynamic input) => input.toString();

abstract class Filterable<T> {
  static final ObjectFilter acceptingAll = (obj, json) => true;

  ValueStream<List<T>> get unfilteredValues;

  int filterWith(ObjectFilter<T> filter);
  void setFilter(int id, ObjectFilter<T> filter);
  void deleteFilter(int id);
  void clearFilters();
}

Iterable<FieldType> getValues<Object, FieldType>(
    List<Object> items, ObjectField<Object, FieldType> field) {
  return items.map(field.getter);
}