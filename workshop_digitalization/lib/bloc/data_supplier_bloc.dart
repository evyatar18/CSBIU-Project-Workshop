abstract class DataSupplierBloc<DataType> {
  List<Field<DataType>> get fields;
  List<Field<DataType>> get visibleFields;


}

abstract class Field<DataType> {

  String get name;

  /// Get the string value of this field for a given object
  String operator[](DataType object);


}