
// import 'package:flutter/material.dart';

// class Table extends ChangeNotifier {
//   final Map<String, Comparator> columns;
//   List<String> _schema;

//   List<Map<String, dynamic>> _objects;
//   List<Map<String, dynamic>> get objects => _objects;

//   Comparator currentSorter;

//   Table(this.columns, int colSortIndex) {
//     // sort according to the first column
//     currentSorter = _ascending(columns.keys.first);
//     _schema = columns.keys.toList();
//   }

//   Comparator _ascending(String columnName) {
//     Comparator comp = columns[columnName];
//     return (o1, o2) => comp(o1[columnName], o2[columnName]);
//   }

//   Comparator _descending(String columnName) {
//     Comparator comp = columns[columnName];
//     return (o1, o2) => comp(o2[columnName], o1[columnName]);
//   }

//   void _checkObjectSchema(Map<String, dynamic> object) {
//     if (!listEquals(object.keys.toList(), _schema)) {
//       throw "Given object schema: ${object.keys.toList()} does not match table schema: $_schema.";
//     }
//   }

//   void addObjects(List<Map<String, dynamic>> objects) {
//     // make sure all objects follow the schema
//     objects.forEach(_checkObjectSchema);

//     _objects.addAll(objects);
//     _stateChanged();
//   }

//   void _stateChanged() {
//     // each time the state changes, must sort again
//     _objects.sort(currentSorter);
//     notifyListeners();
//   }

//   void addObject(Map<String, dynamic> object) {
//     // make sure the object follows the schema
//     _checkObjectSchema(object);

//     _objects.add(object);
//     _stateChanged();
//   }

//   void sort(String column, bool ascending) {
//     if (!columns.containsKey(column)) {
//       throw "Table schema does not contain column $column.";
//     }

//     currentSorter = ascending ? _ascending(column) : _descending(column);
//     _objects.sort(currentSorter);
//     notifyListeners();
//   }
// }
