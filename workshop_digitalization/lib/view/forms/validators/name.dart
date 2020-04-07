import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/extensions/list.dart';

final validators = <String Function(dynamic)>[
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

List<String Function(dynamic)> getNameValidators() => validators.clone();
