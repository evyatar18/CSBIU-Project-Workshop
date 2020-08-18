import 'package:csv/csv.dart';

typedef Map<String, dynamic> _RowConverter(List<dynamic> row);

Stream<Map<String, dynamic>> csvToJson(
    Stream<String> csvDataStream, List<String> fields) {
  return csvDataStream
      .transform(CsvToListConverter(eol: "\n"))
      .map(_makeRowConverter(fields));
}

_RowConverter _makeRowConverter(List<String> fieldOrder) {
  return (row) => _rowToJson(fieldOrder, row);
}

Map<String, dynamic> _rowToJson(List<String> fieldOrder, List<dynamic> row) {
  Map<String, dynamic> json = {};
  if (fieldOrder.length != row.length)
    throw "Given row: $row doesn't have the exact number of required fields (${fieldOrder.length})";

  for (var i = 0; i < row.length; i++) {
    json[fieldOrder[i]] = row[i];
  }
  return json;
}
