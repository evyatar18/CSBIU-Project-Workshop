class StudentSchema {}

// 1. we got a general schema
// 2. we got representations of this schema
// 3. we can convert from one representation to other representation
// 3.1 it might be convenient to have a 'base' schema which can easily be converted
//      to and from
// 4. there should be basic types which can be used to build up easily converted
//    types

// what does a `schema` define?
// 1. value identifiers and their value types

class SchemaConstructionException implements Exception {
  String message;

  SchemaConstructionException(this.message);

  @override
  String toString() => "Schema was not constructed correctly: ${message ?? ""}";
}

// behind every schema there's an object that is being constructed
abstract class Schema<T, X> {
  // make can throw a 'SchemaConstructionException'
  T make(X from);
}

class AtomicSchema<T> implements Schema<T, T> {
  T make(T from) => from;
}

class StringSchema extends AtomicSchema<String> { }
class IntSchema extends AtomicSchema<int> { }



abstract class ComplexSchema<T> implements Schema<T, Map<String, dynamic>> {
  // we define the sub-types(sub-schemas) this schema is made of
  // each type is associated with a name
  // see example in IdSchema
  Map<String, Schema> get constructing;

  bool _testConstructingTypes(Map<String, dynamic> values) {

  }

  T make(Map<String, dynamic> values) {

  }
}

// it's more like a static type, but we will define an instance
// class IdSchema implements ComplexSchema {

//   Map<String, Type> constructing = {
//     "id": StringSchema,
//   };
// }
