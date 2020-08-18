import 'package:csv/csv.dart';

typedef Map<String, dynamic> _RowConverter(List<dynamic> row);

Stream<Map<String, dynamic>> csvToJson(
    Stream<String> csvDataStream, List<String> fields) {
  
  return csvDataStream
      // transfrom csv row to list
      .transform(CsvToListConverter(eol: "\n"))
      // map rach list to map
      .map(_makeRowConverter(fields));
}

_RowConverter _makeRowConverter(List<String> fieldOrder) {
  return (row) => _rowToJson(fieldOrder, row);
}
// get the map of fields names to the fields from row of fields
Map<String, dynamic> _rowToJson(List<String> fieldOrder, List<dynamic> row) {
  Map<String, dynamic> json = {};
  if (fieldOrder.length != row.length)
    throw "Given row: $row doesn't have the exact number of required fields (${fieldOrder.length})";

  for (var i = 0; i < row.length; i++) {
    json[fieldOrder[i]] = row[i];
  }
  return json;
}
