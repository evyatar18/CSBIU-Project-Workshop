import 'dart:math';

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
   var codeUnits = new List.generate(
      length,
      (index){
         return rand.nextInt(33)+89;
      }
   );

   return new String.fromCharCodes(codeUnits);
}
