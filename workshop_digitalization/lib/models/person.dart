import 'package:flamingo/flamingo.dart';

abstract class Person {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String job;
}

class FirebasePerson extends Model implements Person {
  FirebasePerson({
    this.email,
    this.job,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    Map<String, dynamic> values,
  }) : super(values: values);

  @override
  String email;

  @override
  String job;

  @override
  String firstName;

  @override
  String lastName;

  @override
  String phoneNumber;

  factory FirebasePerson.fromPerson(Person person) {
    FirebasePerson p;
    p.email = person.email;
    p.firstName = person.firstName;
    p.lastName = person.lastName;
    p.phoneNumber = person.phoneNumber;
    p.job = person.job;
    return p;
  }

  /// Data for save
  Map<String, dynamic> toData() {
    final data = Map<String, dynamic>();

    writeNotNull(data, "firstName", firstName);
    writeNotNull(data, "lastName", lastName);
    writeNotNull(data, "phone", phoneNumber);
    writeNotNull(data, "email", email);
    writeNotNull(data, "job", job);

    return data;
  }

  /// Data for load
  void fromData(Map<String, dynamic> data) {
    firstName = data["firstName"];
    lastName = data["lastName"];
    phoneNumber = data["phone"];
    email = data["email"];
    job = data["job"];
  }
}
