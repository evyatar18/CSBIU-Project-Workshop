import 'package:redux/redux.dart';

enum RequestType { ADD, REMOVE, CLEAR_LIST }

class _ListChangeRequest<T> {
  final T subject;
  final RequestType request;

  _ListChangeRequest(this.subject, this.request);

  factory _ListChangeRequest.add(T subject) =>
      _ListChangeRequest(subject, RequestType.ADD);

  factory _ListChangeRequest.remove(T subject) =>
      _ListChangeRequest(subject, RequestType.REMOVE);

  factory _ListChangeRequest.clear() =>
      _ListChangeRequest(null, RequestType.CLEAR_LIST);
}

void _doAction<T>(List<T> l, _ListChangeRequest<T> action) {
  switch (action.request) {
    case RequestType.ADD:
      l.add(action.subject);
      break;
    case RequestType.REMOVE:
      l.remove(action.subject);
      break;
    case RequestType.CLEAR_LIST:
      l.clear();
      break;
  }
}

List<T> _requestHandler<T>(List<T> current, action) {
  var ret = List<T>.of(current);
  if (action is _ListChangeRequest<T>) {
    // do single action
    _doAction(ret, action);
  } else if (action is Iterable<_ListChangeRequest<T>>) {
    for (final operation in action) {
      _doAction(ret, operation);
    }
  }

  var casted = ret.cast<T>();
  return casted;
}

class ListModifierHandler<T> {
  final Store<List<T>> _store;

  ListModifierHandler()
      : _store = Store<List<T>>(
          _requestHandler,
          initialState: <T>[],
        );

  void addItem(T item) {
    _store.dispatch(_ListChangeRequest<T>.add(item));
  }

  void removeItem(T item) {
    _store.dispatch(_ListChangeRequest<T>.remove(item));
  }

  void clear() {
    _store.dispatch(_ListChangeRequest<T>.clear());
  }

  void addMany(Iterable<T> items) {
    _store.dispatch(items.map((item) => _ListChangeRequest<T>.add(item)));
  }

  void setItems(List<T> items) {
    _store.dispatch([
      _ListChangeRequest<T>.clear(),
      ...items.map((item) => _ListChangeRequest<T>.add(item))
    ]);
  }

  Iterable<T> where(bool Function(T) where) => latestItems.where(where);

  Stream<List<T>> get items async* {
    yield latestItems;

    await for (var item in _store.onChange) {
      yield item;
    }
  }

  List<T> get latestItems => _store.state;
}
