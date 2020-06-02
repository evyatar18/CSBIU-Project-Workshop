import 'package:workshop_digitalization/files/container.dart';
import 'package:workshop_digitalization/memos/memo.dart';

import '../project/project.dart';
import 'student.dart';

class LocalStudent implements Student {
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
  LocalStudent({
    this.email,
    this.firstName,
    this.lastName,
    this.personalID,
    this.phoneNumber,
    this.status,
    this.studyYear,
  });

  static getFields(){
    return  [
        'id',
        'firstName',
        'lastName',
        'phoneNumber',
        'email',
        'year',
        'status'
      ];
  }

  factory LocalStudent.fromJson(Map<String, dynamic> json) {
    return new LocalStudent(
        email: json["email"],
        firstName: json['firstName'],
        lastName: json['lastName'],
        personalID: json['personalID'],
        phoneNumber: json['phoneNumber'].toString(),
        status: StudentStatus.values[json['status']],
        studyYear: json['studyYear']);
  }

  @override
  // TODO: implement files
  FileContainer get files => null;

  @override
  // TODO: implement id
  String get id => null;

  @override
  // TODO: implement lastUpdate
  DateTime get lastUpdate => null;

  @override
  // TODO: implement loadDate
  DateTime get loadDate => null;

  @override
  // TODO: implement memos
  MemoManager<Memo> get memos => null;

  @override
  // TODO: implement project
  Future<Project> get project => null;

  @override
  void setProject(String projectId) {
    // TODO: implement setProject
  }
}
