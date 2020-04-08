import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/extensions/list.dart';
import 'package:workshop_digitalization/models/data/name.dart';

final _validators = <String Function(dynamic)>[
  FormBuilderValidators.minLength(3,
      errorText: "Name must be at least 3 letters long"),
  FormBuilderValidators.maxLength(48,
      errorText: "Name must be at most 48 characters"),
  FormBuilderValidators.pattern("^[a-zA-Z ]*\$",
      errorText: "Only alphabetic names with spaces"),
  FormBuilderValidators.pattern("[^ ]+ [^ ]+",
      errorText:
          "Names must include space(with characters from left and right)")
];

List<String Function(dynamic)> getNameValidators() => _validators.clone();

dynamic Function(dynamic) getNameValueTransformer() {
  return _nameValueTransformer;
}

dynamic _nameValueTransformer(dynamic value) {
  if (value == null || !(value is String)) {
    throw "Full name value must not be null and be a string.";
  }

  String str = value;

  int firstNameEndIndex = str.lastIndexOf(" ");

  // get first and last names
  final firstName = str.substring(0, firstNameEndIndex);
  final lastName = str.substring(firstNameEndIndex + 1);

  return Name(first: firstName, last: lastName);
}