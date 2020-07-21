import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

typedef Widget ElementForm<T>({
  @required T element,
  @required bool readOnly,
  @required GlobalKey<FormBuilderState> formBuilderKey,
  Map<String, dynamic> initialValues,
});
