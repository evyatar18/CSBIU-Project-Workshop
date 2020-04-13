import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workshop_digitalization/models/data/student.dart';

abstract class DataRepository {
  Stream<QuerySnapshot> getStream();
  Future<DocumentReference> add(Serlizable serlizable);
  void update(Serlizable serlizable);
  void delete(Serlizable serlizable);
}

