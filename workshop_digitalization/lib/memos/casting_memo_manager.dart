import 'package:workshop_digitalization/memos/memo.dart';

class CastingMemoManager<MemoType extends Memo> implements MemoManager<Memo> {
  MemoManager<MemoType> _originalManager;

  CastingMemoManager(this._originalManager);

  @override
  List<Memo> get latestMemos => _originalManager.latestMemos;

  @override
  Stream<List<Memo>> get memos => _originalManager.memos;

  @override
  Future<Memo> createEmpty() => _originalManager.createEmpty();

  MemoType _getOriginalMemo(Memo m) {
    // this is the original memo
    if (m is MemoType) {
      return m;
    }

    // look up the memo, throws an error if no memo found
    return _originalManager.latestMemos
        .firstWhere((element) => element.id == m.id);
  }

  @override
  Future<void> delete(Memo m) => _originalManager.save(_getOriginalMemo(m));

  @override
  Future<MemoType> save(Memo m) => _originalManager.save(_getOriginalMemo(m));
}
