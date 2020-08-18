import 'package:flamingo/flamingo.dart';

import 'grade.dart';

class FirebaseGrade extends Model implements Grade {
  FirebaseGrade({
    Map<String, dynamic> values,
  }) : super(values: values);

  num _grade;

  @override
  set grade(num grade) => _grade = grade;

  @override
  num get grade => _grade == null || _grade.isNaN ? 0.0 : _grade;

  @override
  String comments = "";

  @override
  // Grade to map
  Map<String, dynamic> toData() {
    return <String, dynamic>{
      "comments": comments,
      "grade": grade,
    };
  }

  @override
  // create Grade from map
  void fromData(Map<String, dynamic> data) {
    comments = valueFromKey<String>(data, "comments");
    grade = valueFromKey<num>(data, "grade");
  }
}
