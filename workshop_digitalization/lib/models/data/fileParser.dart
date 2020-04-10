import 'dart:convert';
import 'dart:html';

import 'package:workshop_digitalization/models/data/student.dart';
import 'package:csv/csv.dart';

abstract class FileParser{
  List<Serlizable> Parse(String fileName);
}

class CsvFilePasrser implements FileParser{
  @override
  List<Serlizable> Parse(String fileName) async{
    final input = new File(fileName).openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();

  }
  
  
}