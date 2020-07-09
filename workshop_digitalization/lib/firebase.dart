import 'package:cloud_firestore/cloud_firestore.dart';

const String versionField = "versionName";

CollectionReference firestoreRootCollection;
String currentVersion;

Future<void> initFirebase() async {
  firestoreRootCollection = Firestore.instance.collection("version");
}

Future<List<DocumentSnapshot>> getVersionDocuments() async {
  final query = await firestoreRootCollection.getDocuments();
  return query.documents;
}

Future<DocumentSnapshot> getVersion(String versionName) async {
  final query = await firestoreRootCollection
      .where(versionField, isEqualTo: versionName)
      .getDocuments();

  if (query.documents.isNotEmpty) {
    return query.documents.first;
  }

  final ref = await firestoreRootCollection.add({versionField: versionName});
  return await ref.get();
}

Future<List<String>> getVersions() async {
  final docs = await firestoreRootCollection
      .where("versionName", isGreaterThanOrEqualTo: "")
      .getDocuments();
  return docs.documents.map((doc) => doc.data[versionField]).cast<String>().toList();
}
