import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:workshop_digitalization/extensions/list.dart';

List<String Function(dynamic)> getIsraeliIdValidators() =>
    _israeliIDValidators.clone();

List<String Function(dynamic)> _israeliIDValidators = [
  FormBuilderValidators.required(),
  FormBuilderValidators.pattern("^\\d{9}\$",
      errorText: "Israeli ID must have 9 digits"),
  _israeliIdValidator
];

String _israeliIdValidator(dynamic input) {
  if (input == null) {
    return "Value cannot be null.";
  }

  if (!(input is String)) {
    return "Value must be a string.";
  }

  final String id = input;

  int sum = 0;
  int multiplier = 1;

  /* Israeli ID Validation Formula
   * Iterate over 9 digits
   */
  for (int i = 0; i < 9; ++i) {
    int digit = int.parse(id[i]);

    int result = digit * multiplier;

    if (result >= 10) {
      // summing two digits of result
      result = (result ~/ 10) + (result % 10);
    }

    sum += result;

    // the multiplier flips between 1 and 2
    multiplier = 3 - multiplier;
  }

  return sum % 10 == 0 ? null : "Invalid Israeli ID number";
}
