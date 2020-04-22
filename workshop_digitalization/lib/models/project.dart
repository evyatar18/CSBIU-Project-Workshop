import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flamingo/document.dart';
import 'package:workshop_digitalization/models/person.dart';
import 'package:workshop_digitalization/models/student.dart';

enum ProjectStatus { NEW, Continue }

abstract class Project {
  String initiatorFisrtName;
  String initiatorLastName;

  Person contant;

  String projectSubject;
  String projectDomain;
  String projectGoal;

  DateTime endDate;

  int studentsNumber;

  List<String> skills;

  Person mentor;

  List<String> projectChallenges;
  List<String> projectInnovativeDetails;

  ProjectStatus projectStatus;

  String techAbility;

  List<String> comments;
}

class FirebaseProject extends Document<FirebaseProject> implements Project {
  @override
  List<String> comments;

  FirebasePerson _contant;
  @override
  Person get contant {
    return _contant;
  }
  @override
  void set contant(Person p){
    _contant = FirebasePerson.fromPerson(p);
  }

  @override
  DateTime endDate;

  @override
  String initiatorFisrtName;

  @override
  String initiatorLastName;

  
  @override 
  Person get mentor => _mentor;

  @override
  set mentor(Person p){
    _mentor = FirebasePerson.fromPerson(p);
  }

  FirebasePerson _mentor;

  @override
  List<String> projectChallenges;

  @override
  String projectDomain;

  @override
  String projectGoal;

  @override
  List<String> projectInnovativeDetails;

  @override
  ProjectStatus projectStatus;

  @override
  String projectSubject;

  @override
  List<String> skills;

  @override
  int studentsNumber;

  @override
  String techAbility;

  FirebaseProject({
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
  DateTime get lastUpdate => super.updatedAt.toDate();

  @override
  DateTime get loadDate => super.createdAt.toDate();

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();
    writeNotNull(data, 'initiatorFisrtName', initiatorFisrtName);
    writeNotNull(data, 'initiatorLastName', initiatorLastName);
    writeModelNotNull(data, 'contant', _contant);
    writeNotNull(data, 'projectSubject', projectSubject);
    writeNotNull(data, 'projectDomain', projectDomain);
    writeNotNull(data, 'projectGoal', projectGoal);
    writeNotNull(data, 'endDate', endDate);
    writeNotNull(data, 'studentsNumber', studentsNumber);
    writeNotNull(data, 'skills', skills);
    writeModelNotNull(data, 'mentor', _mentor);
    writeNotNull(data, 'projectChallenges', projectChallenges);
    writeNotNull(data, 'projectInnovativeDetails', projectInnovativeDetails);
    writeNotNull(data, 'projectStatus', projectStatus);
    writeNotNull(data, 'techAbility', techAbility);
    writeNotNull(data, 'comments', comments);
    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    
      comments =  List<String>.from(data['comments']);
      contant =FirebasePerson(values: valueMapFromKey(data, 'contant'));
      endDate = (data['endDate'] as Timestamp).toDate();
      initiatorFisrtName =  data['initiatorFisrtName'];
      initiatorLastName = data['initiatorLastName'];
      mentor =  FirebasePerson(values: valueMapFromKey(data, 'mentor'));
      projectChallenges=  valueListFromKey(data, 'projectChallenges');
      projectDomain = data['projectDomain'];
      projectGoal = data['projectGoal'];
      projectInnovativeDetails =valueListFromKey(data, 'projectInnovativeDetails');
      projectStatus = ProjectStatus.values[data['projectStatus']];
      projectSubject = data['projectSubject'];
      skills = valueListFromKey(data, 'skills');
      studentsNumber = data['studentsNumber'];
      techAbility = data['techAbility'];
    
  }


  
}
