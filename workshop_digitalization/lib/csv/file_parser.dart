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
        .transform(new CsvToListConverter(eol: "\n"))
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
      json[fieldOrder[i]] = row[i];
    }
    return json;
  }
}