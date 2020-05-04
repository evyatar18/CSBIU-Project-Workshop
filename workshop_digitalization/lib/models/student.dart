import 'package:flamingo/flamingo.dart';
import 'package:json_table/json_table.dart';
import 'package:workshop_digitalization/models/jsonable.dart';
import 'package:workshop_digitalization/models/tableHeaders.dart';

enum StudentStatus { SEARCHING, WORKING, FINISHED, IRRELEVANT }

StudentStatus DEFAULT_STATUS = StudentStatus.SEARCHING;

// student interface
abstract class Student implements Jsonable{
  String personalID;
  String firstName, lastName;
  String phoneNumber;
  String email;

  int studyYear;

  StudentStatus status;

  DateTime get lastUpdate;
  DateTime get loadDate;

  Map<String, dynamic> toJson();
  
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
            collectionRef: collectionRef);

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

  StudentStatus _status;
  @override
  StudentStatus get status => _status ?? DEFAULT_STATUS;
  set status(StudentStatus stat) => _status = stat;

  @override
  int studyYear;


  // TODO: convert timezones if needed
  @override
  DateTime get lastUpdate => super.updatedAt!=null?super.updatedAt.toDate():null;

  @override
  DateTime get loadDate => super.createdAt!=null ?super.createdAt.toDate():null;

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();

    writeNotNull(data, "id", personalID);
    writeNotNull(data, "firstName", firstName);
    writeNotNull(data, "lastName", lastName);
    writeNotNull(data, "phone", phoneNumber);
    writeNotNull(data, "email", email);
    writeNotNull(data, "year", studyYear);
    if (status!=null) writeNotNull(data, "status", status.index);

    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    personalID = valueFromKey<String>(data, "id");
    firstName = valueFromKey<String>(data, "firstName");
    lastName = valueFromKey<String>(data, "lastName");
    phoneNumber = valueFromKey<String>(data, "phone");
    email = valueFromKey<String>(data, "email");
    studyYear = valueFromKey<int>(data, "year");
    status = StudentStatus.values[valueFromKey<int>(data, "status")];
  }

  @override
  Map<String, dynamic> toJson() {
    return toData();
  }
}
