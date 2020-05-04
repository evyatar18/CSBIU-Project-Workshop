

import 'package:flutter/cupertino.dart';
import 'package:workshop_digitalization/models/jsonable.dart';

abstract class JsonableDetails implements Widget {
  JsonableDetails(Jsonable s);
}

abstract class JsonableDetailsFactory {
  JsonableDetails create(Jsonable s);
}