library form_types;

import 'package:workshop_digitalization/models/data/name.dart';
import 'package:workshop_digitalization/view/forms/types/form_israeli_id.dart';
import 'package:workshop_digitalization/view/forms/types/form_name.dart';

final _Validators validators = _Validators();
final _ValueTransformers valueTransformers = _ValueTransformers();

class _Validators {
  List<dynamic Function(dynamic)> get israeliId => getIsraeliIdValidators();
  List<dynamic Function(dynamic)> get name => getNameValidators();
}

class _ValueTransformers {
  Name Function(dynamic) get nameFromString => getNameValueTransformer();
}