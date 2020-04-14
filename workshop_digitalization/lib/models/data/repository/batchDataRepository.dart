import 'package:cloud_firestore/cloud_firestore.dart';

import '../student.dart';
import 'dataRepository.dart';

abstract class BatchDataRepository extends DataRepository {
  void commit();
}

class FirebaseBatchDataRepository implements BatchDataRepository {
  final  collection;
  var batch;
  FirebaseBatchDataRepository(String collectionName)
      : collection = Firestore.instance.collection(collectionName);

  
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> add(Serlizable serlizable) async{
    if(batch==null) 
      batch = Firestore.instance.batch();
    var docRef = collection.document();
    await batch.setData(docRef,serlizable.toJson());
    return Future<DocumentReference>.value(docRef);
  }

  void update(Serlizable serlizable) async {
    if(batch==null) 
      batch = Firestore.instance.batch();
    batch.updateData(serlizable.reference,serlizable.toJson());
  }

  void commit() async{
    await batch.commit();
    batch = null;
  }

  @override
  void delete(Serlizable serlizable) async{
    if(batch==null) 
      batch = Firestore.instance.batch();
    batch.delete(serlizable.reference);
  }
}