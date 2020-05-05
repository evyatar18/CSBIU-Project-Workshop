import 'package:flutter/material.dart';

import 'jsonable.dart';

abstract class JsonableDetails implements Widget {
  JsonableDetails(Jsonable s);
}

abstract class JsonableDetailsFactory {
  JsonableDetails create(Jsonable s);
}
