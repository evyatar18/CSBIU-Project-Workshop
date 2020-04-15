import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workshop_digitalization/models/data/student.dart';

abstract class DataRepository {
  Stream<QuerySnapshot> getStream();
  Future<DocumentReference> add(Serlizable serlizable);
  Future<void> update(Serlizable serlizable);
  Future<void> delete(Serlizable serlizable);
}

