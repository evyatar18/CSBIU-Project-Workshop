import 'package:workshop_digitalization/files/container.dart';
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

  @override
  // TODO: implement attachedFiles
  FileContainer get attachedFiles => throw "no files";

  @override
  // TODO: implement id
  String get id => "hello";
}