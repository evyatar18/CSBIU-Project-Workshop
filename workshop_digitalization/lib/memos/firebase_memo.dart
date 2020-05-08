import 'package:flamingo/flamingo.dart';
import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/files/file_utils.dart';
import 'package:workshop_digitalization/files/firebase.dart';
import 'package:workshop_digitalization/global/list_modifier.dart';

import 'memo.dart';

class Definitions {
  static final topicField = "topic";
  static final contentField = "content";

  static final filesCollection = "files";
}

class FirebaseMemo extends Document<FirebaseMemo> implements Memo {
  FileContainer _container;

  FirebaseMemo({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }) : super(
          id: id,
          snapshot: snapshot,
          values: values,
          collectionRef: collectionRef,
        ) {
    // default container is FirebaseFileContainer
    _container = FBFileContainer(
        super.reference.collection(Definitions.filesCollection));
      print(super.reference.path);
  }

  @override
  String get id => super.id;

  @override
  DateTime get lastUpdate => super.updatedAt.toDate();

  @override
  DateTime get creationDate => super.createdAt.toDate();

  @override
  String content = "";

  @override
  String topic = "";

  @override
  FileContainer get attachedFiles => _container;

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();
    writeNotNull(data, Definitions.topicField, topic);
    writeNotNull(data, Definitions.contentField, content);
    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    topic = valueFromKey<String>(data, Definitions.topicField);
    content = valueFromKey<String>(data, Definitions.contentField);
  }
}

class FirebaseMemoManager implements MemoManager<FirebaseMemo> {
  CollectionReference _memoCollection;
  final _memoList = ListModifierHandler<FirebaseMemo>();
  final _docAccessor = DocumentAccessor();

  FirebaseMemoManager(this._memoCollection) {
    _memoCollection.snapshots().listen(_onFirebaseUpdate);
  }

  @override
  Stream<List<FirebaseMemo>> get memos => _memoList.items;

  @override
  List<FirebaseMemo> get latestMemos => _memoList.latestItems;

  void _onFirebaseUpdate(QuerySnapshot snapshot) {
    _memoList.setItems(
      (snapshot)
          .documents
          .where((doc) => doc.exists)
          .map((doc) => FirebaseMemo(snapshot: doc, collectionRef: _memoCollection))
          .toList(),
    );
  }

  @override
  Future<FirebaseMemo> createEmpty() async {
    final memo = FirebaseMemo(collectionRef: _memoCollection);

    // save creation date
    await _docAccessor.save(memo);

    return memo;
  }

  @override
  Future<void> delete(FirebaseMemo memo) async {
    // clear file container
    await clearFileContainer(memo.attachedFiles);

    // delete document
    await memo.reference.delete();
  }

  @override
  Future<void> save(FirebaseMemo m) async {
    await _docAccessor.update(m);
  }
}
