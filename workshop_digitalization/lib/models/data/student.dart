import 'name.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum StudentStatus { SEARCHING, WORKING, FINISHED, IRRELEVANT }

abstract class Serlizable {
  DocumentReference reference;
  Map<String, dynamic> toJson();
  Serlizable.fromList(List<dynamic> list);

}

abstract class Student implements Serlizable {
  String id;
  Name fullName;
  String phoneNumber;
  String email;

  int studyYear;

  StudentStatus status;

  DateTime lastUpdate;
  DateTime loadDate;
  
  DocumentReference reference;

  Map<String, dynamic> toJson();
}

class DBStudent implements Student {
  String id;
  Name fullName;
  String phoneNumber;
  String email;

  int studyYear;

  StudentStatus status;

  DateTime lastUpdate;
  DateTime loadDate;

  DocumentReference reference;

  DBStudent(
      {@required this.id,
      @required this.fullName,
      @required this.phoneNumber,
      @required this.email,
      @required this.studyYear,
      @required this.status,
      @required this.lastUpdate,
      @required this.loadDate,
      this.reference});

  DBStudent.fromJson(Map<dynamic, dynamic> json, {this.reference}) {
      id = json['id'];
      fullName =  Name(first: json['name']['first'], last: json['name']['last']);
      phoneNumber = json['phone'];
      email = json['email'];
      studyYear = json['year'];
      status = json['status'];
      print(json['lastUpdate']);
      if(json['lastUpdate'] != null)
        lastUpdate =( json['lastUpdate'] as Timestamp).toDate();
      loadDate = json['loadDate'];
  }
  DBStudent.fromList(List<dynamic> list){
    
  }


  factory DBStudent.fromSnapshot(DocumentSnapshot snapshot){
    return DBStudent.fromJson(snapshot.data,reference: snapshot.reference);
  }

  Map<String, dynamic> toJson() => _DBStudentToJson(this);
  
  @override
  String toString() => "DBStudent<$DBStudent>";
}

// DBStudent _DBStudentFromJson(Map<dynamic, dynamic> json, {this.reference}) {
//   return DBStudent(
//       id: json['id'],
//       fullName: Name(first: json['name']['first'], last: json['name']['last']),
//       phoneNumber: json['phone'],
//       email: json['email'],
//       studyYear: json['year'],
//       status: json['status'],
//       lastUpdate: json['lastUpdate'],
//       loadDate: json['loadDate']);
// }

Map<String, dynamic> _DBStudentToJson(DBStudent instance) => <String, dynamic>{
      'id': instance.id,
      'name': {
        'first': instance.fullName.first,
        'last': instance.fullName.last
      },
      'phone': instance.phoneNumber,
      'email': instance.email,
      'year': instance.studyYear,
      'status': instance.status,
      'lastUpdate': DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      'loadDate': instance.loadDate
    };
