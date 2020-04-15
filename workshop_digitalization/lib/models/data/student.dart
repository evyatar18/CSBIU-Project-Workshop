import 'name.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum StudentStatus { SEARCHING, WORKING, FINISHED, IRRELEVANT }

abstract class Serlizable {
  DocumentReference reference;
  Map<String, dynamic> toJson();
  Serlizable.fromJson(Map<dynamic, dynamic> json, {this.reference});
  static List<String> getFields(){return [];} 
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

  @override
  static List<String> getFields(){
    return ['id','name.first','name.last','phoneNumber','email','year','status','lastUpdate','loadDate',];
  }
}

// class LocalStudent extends Student{

// }

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
      id = (json['id'].toString());
      fullName =  Name(first: json['name']['first'], last: json['name']['last']);
      phoneNumber = json['phone'];
      email = json['email'];
      studyYear = json['year'];
      status = StudentStatus.values[json['status']];
      if(json['lastUpdate'] != null){
        if (json['lastUpdate'] is Timestamp)
          lastUpdate =( json['lastUpdate'] as Timestamp).toDate();
        else
          lastUpdate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      }
      if (json['loadDate'] == null)
        loadDate = json['loadDate'];
      else
        loadDate = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
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
      'status': instance.status.index,
      'lastUpdate': DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      'loadDate': instance.loadDate
    };
