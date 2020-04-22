import 'package:flamingo/flamingo.dart';

enum StudentStatus { SEARCHING, WORKING, FINISHED, IRRELEVANT }

// student interface
abstract class Student {
  String personalID;
  String firstName, lastName;
  String phoneNumber;
  String email;

  int studyYear;

  StudentStatus status;

  DateTime get lastUpdate;
  DateTime get loadDate;


}

class FirebaseStudent extends Document<FirebaseStudent> implements Student {
  FirebaseStudent({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }) : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef: collectionRef) {}

  @override
  String email;

  @override
  String firstName;

  @override
  String lastName;

  @override
  String personalID;

  @override
  String phoneNumber;

  @override
  StudentStatus status;

  @override
  int studyYear;


  // TODO: convert timezones if needed
  @override
  DateTime get lastUpdate => super.updatedAt.toDate();

  @override
  DateTime get loadDate => super.createdAt.toDate();

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();

    writeNotNull(data, "id", personalID);
    writeNotNull(data, "firstName", firstName);
    writeNotNull(data, "lastName", lastName);
    writeNotNull(data, "phone", phoneNumber);
    writeNotNull(data, "email", email);
    writeNotNull(data, "year", studyYear);
    writeNotNull(data, "status", status.index);

    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    personalID = data["id"];
    firstName = data["firstName"];
    lastName = data["lastName"];
    phoneNumber = data["phone"];
    email = data["email"];
    studyYear = data["year"];
    status = StudentStatus.values[data["status"]];
  }
}
