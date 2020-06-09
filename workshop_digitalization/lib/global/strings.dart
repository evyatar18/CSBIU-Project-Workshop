import 'dart:math';

import 'package:intl/intl.dart';

String byteSizeString(int bytes) {
  int kb = 1000;
  int mb = kb * kb;

  if (bytes >= mb) {
    var displayedSize = (bytes * 10 / mb).round() / 10;
    return "${displayedSize}MB";
  } else if (bytes >= kb) {
    var displayedSize = (bytes * 10 / kb).round() / 10;
    return "${displayedSize}KB";
  } else {
    return "${bytes}B";
  }
}

String randomString(int length) {
  var rand = new Random();
  var codeUnits = new List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return new String.fromCharCodes(codeUnits);
}

String capitalizeWord(String word) =>
    word.isEmpty ? "" : word[0].toUpperCase() + word.substring(1).toLowerCase();

String capitalize(String s) {
  return s.splitMapJoin(" ", onNonMatch: capitalizeWord);
}

final dateFormat = DateFormat.yMd().add_Hms();
String writeDate(DateTime dt) => dateFormat.format(dt);
