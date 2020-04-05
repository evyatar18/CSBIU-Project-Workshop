import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workshop_digitalization/models/data/student.dart';

abstract class DataRepository {
  Stream<QuerySnapshot> getStream();
  Future<DocumentReference> addStudent(Student student);
  void updateStudent(Student student);
  void deleteStudent(Student student);
}


class StudentDataRepository implements DataRepository {
  final CollectionReference collection ;
  StudentDataRepository(String collectionName):collection = Firestore.instance.collection(collectionName);

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future<DocumentReference> addStudent(Student student) {
    return collection.add(student.toJson());
    /**
     * await collection
      .document(student.id)
      .setData(student.toJson())
     */
  }

  void updateStudent(Student student) async {
    if(student.reference!=null )
      await collection.document(student.reference.documentID).updateData(student.toJson());
      else{
        //check this
        student.reference =await addStudent(student);
      }
  }

  void deleteStudent(Student student) {
    try {
      collection.document(student.reference.documentID)
        .delete();
    } catch (e) {
      print(e.toString());
    } 
  }
}
