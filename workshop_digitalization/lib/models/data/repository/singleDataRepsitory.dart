

import 'package:cloud_firestore/cloud_firestore.dart';

import '../student.dart';
import 'dataRepository.dart';

class SingleDataRepository implements DataRepository {
  final CollectionReference collection;
  SingleDataRepository(String collectionName)
      : collection = Firestore.instance.collection(collectionName);
  
  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> add(Serlizable serlizable) {
    return collection.add(serlizable.toJson());
  }

  Future<void> update(Serlizable serlizable) async {
    if (serlizable.reference != null)
      await collection
          .document(serlizable.reference.documentID)
          .updateData(serlizable.toJson());
    else {
      serlizable.reference = await add(serlizable);
    }
  }

  Future<void> delete(Serlizable serlizable) {
    try {
      collection.document(serlizable.reference.documentID).delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
