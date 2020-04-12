import 'dart:convert';
import 'dart:io';

import 'package:workshop_digitalization/models/data/student.dart';
import 'package:csv/csv.dart';

abstract class FileParser{
  Future<List<List<dynamic>>> Parse(String fileName);

}

class CsvFilePasrser implements FileParser{
  @override
  Future<List<List<dynamic>>> Parse(String fileName){
    final input = new File(fileName).openRead();
    Future<List<List<dynamic>>> fields = (input.transform(utf8.decoder).transform(new CsvToListConverter()).toList());
    return fields;
  }
}