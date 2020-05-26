import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

abstract class FileParser {
  Future<List<Map<String, dynamic>>> parse(String fileName, List<String> fieldOrder);
}

typedef Map<String, dynamic> _RowConverter(List<dynamic> row);

class CsvFileParser implements FileParser {
  @override
  Future<List<Map<String, dynamic>>> parse(String fileName, List<String> fieldOrder) async {

    final input = new File(fileName).openRead();
    List<Map<String, dynamic>> fields = await input
        .transform(utf8.decoder)
        .transform(new CsvToListConverter())
        .map(_makeRowConverter(fieldOrder))
        .toList();

    return fields;
  }

  _RowConverter _makeRowConverter(List<String> fieldOrder) {
    return (row) => _rowToJson(fieldOrder, row);
  }

  Map<String, dynamic> _rowToJson(List<String> fieldOrder, List<dynamic> row) {
    Map<String, dynamic> json = {};
    if (fieldOrder.length != row.length) throw ("");

    for (var i = 0; i < row.length; i++) {
      final path = fieldOrder[i].split('.');
      Map<String, dynamic> current = json;

      for (int j = 0; j < path.length - 1; ++j) {
        final subPath = path[j];
        if (!current.containsKey(subPath)) {
          current[subPath] = Map<String, dynamic>();
        }
        current = current[subPath];
      }

      current[path[path.length - 1]] = row[i];
    }
    return json;
  }
}