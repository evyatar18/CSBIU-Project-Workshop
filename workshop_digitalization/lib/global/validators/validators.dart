import 'package:flutter_form_builder/flutter_form_builder.dart';

final phoneValidators = [
  FormBuilderValidators.required(),
  FormBuilderValidators.pattern(
    "^\\d+-?\\d+\$",
    errorText: "a phone may only contain numbers and one dash",
  )
];
