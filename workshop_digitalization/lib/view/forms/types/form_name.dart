import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/utils/extensions.dart';
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

Name Function(dynamic) getNameValueTransformer() => _nameValueTransformer;

Name _nameValueTransformer(dynamic value) {
  if (value == null || !(value is String)) {
    throw "Full name value must not be null and be a string.";
  }

  String str = value;

  int firstNameLastIndex = str.lastIndexOf(" ");

  // we got both first and last names
  if (firstNameLastIndex != -1) {
    // get first and last names
    final firstName = str.substring(0, firstNameLastIndex);
    final lastName = str.substring(firstNameLastIndex + 1);

    return Name(first: firstName, last: lastName);
  } else {
    return Name(first: value, last: "");
  }
}