import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';

enum RequestType { ADD, REMOVE, CLEAR_LIST, FOR_EACH }

typedef void ForEach<T>(T elem);

/// this is a thread-safe list
///
/// operations on it are done using the redux mechanism
///
/// it means you make a request to do an operation, and it is done atomically
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

  void forEach(ForEach<T> func) {
    _store.dispatch(_ListChangeRequest.forEach(func));
  }

  void forEachAndSet(ForEach<T> func, List<T> items) {
    final actions = [
      _ListChangeRequest.forEach(func),
      _ListChangeRequest<T>.clear(),
      ...items.map((item) => _ListChangeRequest<T>.add(item))
    ];

    _store.dispatch(actions);
  }

  Iterable<T> where(bool Function(T) where) => latestItems.where(where);

  Stream<List<T>> get items => ConcatStream([
        Stream.value(latestItems),
        _store.onChange,
      ]);

  List<T> get latestItems => _store.state;
}

/// defines a request to change the list
class _ListChangeRequest<T> {
  final T subject;
  final RequestType request;
  ForEach<T> forEach;

  _ListChangeRequest(this.subject, this.request, [this.forEach]);

  factory _ListChangeRequest.add(T subject) =>
      _ListChangeRequest(subject, RequestType.ADD);

  factory _ListChangeRequest.remove(T subject) =>
      _ListChangeRequest(subject, RequestType.REMOVE);

  factory _ListChangeRequest.clear() =>
      _ListChangeRequest(null, RequestType.CLEAR_LIST);

  factory _ListChangeRequest.forEach(ForEach<T> func) =>
      _ListChangeRequest(null, RequestType.FOR_EACH, func);
}

/// does an action on the list
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
    case RequestType.FOR_EACH:
      try {
        l.forEach(action.forEach);
      } catch (e) {}
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
