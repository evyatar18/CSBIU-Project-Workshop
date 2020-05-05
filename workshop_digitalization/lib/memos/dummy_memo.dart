import 'package:workshop_digitalization/memos/memo.dart';

class Mem implements Memo {
  @override
  String content = 'sdfsf';

  @override
  String topic = 'MEMO';

  @override
  DateTime get creationDate =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  DateTime get lastUpdate => null;
}