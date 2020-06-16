import 'package:flamingo/flamingo.dart';

import 'grade.dart';

class FirebaseGrade extends Model implements Grade {
  FirebaseGrade({
    Map<String, dynamic> values,
  }) : super(values: values);

  @override
  num grade = double.nan;

  @override
  String comments = "";

  @override
  Map<String, dynamic> toData() {
    return <String, dynamic>{
      "comments": comments,
      "grade": grade,
    };
  }

  @override
  void fromData(Map<String, dynamic> data) {
    comments = valueFromKey<String>(data, "comments");
    grade = valueFromKey<num>(data, "grade");
  }
}
