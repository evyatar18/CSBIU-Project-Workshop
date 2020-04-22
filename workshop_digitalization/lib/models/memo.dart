import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/document.dart';

abstract class Memo {
  String topic;
  String content;
  DateTime creationDate;
}

class FirebaseMemo extends Document<FirebaseMemo> implements Memo {
  @override
  String content;

  @override
  String topic;

  @override
  DateTime creationDate;

  FirebaseMemo({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }) : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef: collectionRef);

  @override
  DateTime get lastUpdate => super.updatedAt.toDate();

  @override
  DateTime get loadDate => super.createdAt.toDate();

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();
    writeNotNull(data, 'topic', topic);
    writeNotNull(data, 'content', content);
    writeNotNull(data, 'creationDate', creationDate);
    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    topic = valueFromKey<String>(data, 'topic');
    content = valueFromKey<String>(data, 'comntent');
    creationDate = valueFromKey<Timestamp>(data, 'creationDate').toDate();
  }
}
