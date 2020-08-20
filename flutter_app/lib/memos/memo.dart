import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/global/disposable.dart';
import 'package:workshop_digitalization/global/identified_type.dart';

abstract class Memo implements StringIdentified {
  String topic;
  String content;

  DateTime get creationDate;
  DateTime get lastUpdate;

  FileContainer get attachedFiles;
}

abstract class MemoManager<MemoType extends Memo> implements Disposable {
  Stream<List<MemoType>> get memos;
  List<MemoType> get latestMemos;

  Future<void> delete(MemoType m);
  Future<MemoType> createEmpty();
  Future<void> save(MemoType m);
}