import 'package:workshop_digitalization/global/identified_type.dart';

abstract class ElementManager<T extends StringIdentified> {
  Future<T> createEmpty();

  Future<void> delete(T elem);
  Future<void> save(T elem);

  T getById(String id);
}