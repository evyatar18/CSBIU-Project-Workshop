import 'package:cloud_firestore/cloud_firestore.dart';

import '../student.dart';
import 'dataRepository.dart';

abstract class BatchDataRepository extends DataRepository {
  Future<void> commit();
}

class FirebaseTransactionDataRepository implements BatchDataRepository {
  final collection;
  List<Serlizable> updates = [];
  List<Serlizable> adds = [];
  List<Serlizable> deletes = [];
  FirebaseTransactionDataRepository(String collectionName)
      : collection = Firestore.instance.collection(collectionName);

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }
   
  void _init(){
    updates = [];
    adds =[];
    deletes = [];
  }

  Future<DocumentReference> add(Serlizable serlizable) async {
    var docRef = collection.document();
    adds.add(serlizable);
    return docRef;
  }

  Future<void> update(Serlizable serlizable) async {
    updates.add(serlizable);
  }

  Future<void> commit() async {
   var localAdds = adds; 
   var localUpdates = updates;
   var localDelets = deletes;
   _init();

  }

  @override
  Future<void> delete(Serlizable serlizable) async {
    deletes.add(serlizable);
  }
}

class FirebaseBatchDataRepository implements BatchDataRepository {
  final collection;
  var batch;
  FirebaseBatchDataRepository(String collectionName)
      : collection = Firestore.instance.collection(collectionName);

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> add(Serlizable serlizable) async {
    if (batch == null) batch = Firestore.instance.batch();
    var docRef = collection.document();
    batch.setData(docRef, serlizable.toJson());
    return docRef;
  }

  Future<void> update(Serlizable serlizable) async {
    if (batch == null) batch = Firestore.instance.batch();
    batch.updateData(serlizable.reference, serlizable.toJson());
  }

  Future<void> commit() async {
    var localBatch = batch;
    batch = null;
    await localBatch.commit();
    print("commited");
  }

  @override
  Future<void> delete(Serlizable serlizable) async {
    if (batch == null) batch = Firestore.instance.batch();
    batch.delete(serlizable.reference);
  }
}
