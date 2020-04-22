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
    return new FirebasePerson(
        email: person.email,
        job: person.job,
        firstName: person.firstName,
        lastName: person.lastName,
        phoneNumber: person.phoneNumber);
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
    firstName = valueFromKey(data,"firstName");
    lastName = valueFromKey(data,"lastName");
    phoneNumber = valueFromKey(data,"phone");
    email = valueFromKey(data,"email");
    job = valueFromKey(data,"job");
  }
}
