import 'package:flamingo/flamingo.dart';
import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/files/firebase.dart';
import 'package:workshop_digitalization/memos/firebase_memo.dart';
import 'package:workshop_digitalization/memos/memo.dart';

import 'student.dart';

class FirebaseStudent extends Document<FirebaseStudent> implements Student {
  FBFileContainer _files;
  MemoManager<Memo> _memos;

  FirebaseStudent({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }) : super(
          id: id,
          snapshot: snapshot,
          values: values,
          collectionRef: collectionRef,
        ) {
    _files = FBFileContainer(super.reference.collection("files"));
    _memos = FirebaseMemoManager(super.reference.collection("memos"));
  }

  @override
  FileContainer get files => _files;

  @override
  MemoManager<Memo> get memos => _memos;

  @override
  String email = "";

  @override
  String firstName = "";

  @override
  String lastName = "";

  @override
  String personalID = "";

  @override
  String phoneNumber = "";

  StudentStatus _status;
  @override
  StudentStatus get status => _status ?? DEFAULT_STATUS;
  set status(StudentStatus stat) => _status = stat;

  @override
  int studyYear = DateTime.now().year;

  // TODO: convert timezones if needed
  @override
  DateTime get lastUpdate =>
      super.updatedAt != null ? super.updatedAt.toDate() : DateTime.now();

  @override
  DateTime get loadDate =>
      super.createdAt != null ? super.createdAt.toDate() : DateTime.now();

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();

    writeNotNull(data, "id", personalID);
    writeNotNull(data, "firstName", firstName);
    writeNotNull(data, "lastName", lastName);
    writeNotNull(data, "phone", phoneNumber);
    writeNotNull(data, "email", email);
    writeNotNull(data, "year", studyYear);
    if (status != null) writeNotNull(data, "status", status.index);

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
