// import 'package:flamingo/flamingo.dart';
// import 'firebase.dart';

// class TestFileDocument extends Document<TestFileDocument> {
//   TestFileDocument({
//     String id,
//     DocumentSnapshot snapshot,
//     Map<String, dynamic> values,
//     CollectionReference collectionRef,
//   }) : super(
//           id: id,
//           snapshot: snapshot,
//           values: values,
//           collectionRef: collectionRef,
//         ) {
//           // fc = FirebaseFileContainer(filesStoragePath)
//         }

//   FirebaseFileContainer fc;

//   /// Data for save
//   Map<String, dynamic> toData() {
//     final data = <String, dynamic>{};
//     writeModelNotNull(data, "files", fc);

//     return data;
//   }

//   /// Data for load
//   void fromData(Map<String, dynamic> data) {
//     // super.valueFromKey(data, key)
//     fc.fromData(data);
//   }
// }
