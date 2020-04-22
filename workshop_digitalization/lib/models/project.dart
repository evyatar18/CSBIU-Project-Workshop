import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/document.dart';
import 'package:workshop_digitalization/models/person.dart';

enum ProjectStatus { NEW, CONTINUE }

abstract class Project {
  String initiatorFirstName;
  String initiatorLastName;

  Person contact;

  String projectSubject;
  String projectDomain;
  String projectGoal;

  DateTime endDate;

  int numberOfStudents;

  List<String> skills;

  Person mentor;

  List<String> projectChallenges;
  List<String> projectInnovativeDetails;

  ProjectStatus projectStatus;

  String mentorTechAbility;

  List<String> comments;
}

class FirebaseProject extends Document<FirebaseProject> implements Project {
  @override
  List<String> comments;

  FirebasePerson _contact;
  @override
  Person get contact {
    return _contact;
  }

  @override
  set contact(Person p) {
    _contact = FirebasePerson.fromPerson(p);
  }

  @override
  DateTime endDate;

  @override
  String initiatorFirstName;

  @override
  String initiatorLastName;

  @override
  Person get mentor => _mentor;

  @override
  set mentor(Person p) {
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
  int numberOfStudents;

  @override
  String mentorTechAbility;

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
    writeNotNull(data, 'initiatorFirstName', initiatorFirstName);
    writeNotNull(data, 'initiatorLastName', initiatorLastName);
    writeModelNotNull(data, 'contact', _contact);
    writeNotNull(data, 'projectSubject', projectSubject);
    writeNotNull(data, 'projectDomain', projectDomain);
    writeNotNull(data, 'projectGoal', projectGoal);
    writeNotNull(data, 'endDate', endDate);
    writeNotNull(data, 'numberOfStudents', numberOfStudents);
    writeNotNull(data, 'skills', skills);
    writeModelNotNull(data, 'mentor', _mentor);
    writeNotNull(data, 'projectChallenges', projectChallenges);
    writeNotNull(data, 'projectInnovativeDetails', projectInnovativeDetails);
    writeNotNull(data, 'projectStatus', projectStatus);
    writeNotNull(data, 'mentorTechAbility', mentorTechAbility);
    writeNotNull(data, 'comments', comments);
    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    comments = valueListFromKey<String>(data, 'comments');
    contact = FirebasePerson(
        values: valueMapFromKey<String, dynamic>(data, 'contact'));
    endDate = valueFromKey<Timestamp>(data, 'endDate').toDate();
    initiatorFirstName = valueFromKey<String>(data, 'initiatorFirstName');
    initiatorLastName = valueFromKey<String>(data, 'initiatorLastName');
    mentor = FirebasePerson(
        values: valueMapFromKey<String, dynamic>(data, 'mentor'));
    projectChallenges = valueListFromKey<String>(data, 'projectChallenges');
    projectDomain = valueFromKey<String>(data, 'projectDomain');
    projectGoal = valueFromKey<String>(data, 'projectGoal');
    projectInnovativeDetails =
        valueListFromKey<String>(data, 'projectInnovativeDetails');
    projectStatus =
        ProjectStatus.values[valueFromKey<int>(data, 'projectStatus')];
    projectSubject = valueFromKey<String>(data, 'projectSubject');
    skills = valueListFromKey<String>(data, 'skills');
    numberOfStudents = valueFromKey<int>(data, 'numberOfStudents');
    mentorTechAbility = valueFromKey<String>(data, 'mentorTechAbility');
  }
}
