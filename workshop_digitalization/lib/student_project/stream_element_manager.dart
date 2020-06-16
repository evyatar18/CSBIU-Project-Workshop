import 'package:workshop_digitalization/global/identified_type.dart';

import 'element_manager.dart';

class StreamElementManager<T extends StringIdentified>
    implements ElementManager<T> {
  final ElementManager<T> elementManager;
  final Stream<void> onSavedStream;

  StreamElementManager(this.elementManager, Stream<void> onSavedStream)
      : this.onSavedStream = onSavedStream.asBroadcastStream();

  @override
  Future<T> createEmpty() => elementManager.createEmpty();

  @override
  Future<void> delete(T elem) => elementManager.delete(elem);

  @override
  T getById(String id) => elementManager.getById(id);

  @override
  Future<void> save(T elem) async {
    // wait for save
    await onSavedStream.take(1).first;
    elementManager.save(elem);
  }
}
