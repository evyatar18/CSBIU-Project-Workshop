import 'dart:async';

import 'package:mutex/mutex.dart';
import 'package:workshop_digitalization/global/disposable.dart';

import 'progress.dart';

/// applies a change to the map of progress snapshots
typedef void _Change(Map<int, ProgressSnapshot> snapshots);

class ProgressRepository implements Disposable {
  Stream<List<IdentifiedProgressSnapshot>> _snapshots;
  bool _running;

  var _current = <IdentifiedProgressSnapshot>[];

  ProgressRepository() : _running = true {
    _snapshots = _changeStream().asBroadcastStream();
  }

  final _pendingChanges = StreamController<_Change>();

  Stream<List<IdentifiedProgressSnapshot>> _changeStream() async* {
    var currentSnapshots = <int, ProgressSnapshot>{};

    await for (final change in _pendingChanges.stream) {
      var cpy = Map.of(currentSnapshots);
      change(cpy);
      currentSnapshots = cpy;

      yield _current = cpy.entries
          .map((entry) => IdentifiedProgressSnapshot(entry.key, entry.value))
          .toList();
    }
  }

  Stream<List<IdentifiedProgressSnapshot>> get snapshots => _snapshots;
  List<IdentifiedProgressSnapshot> get latestSnapshots => _current;

  final _newSnapshots = StreamController<int>();
  Stream<int> get newSnapshotListener => _newSnapshots.stream;

  final _idMutex = Mutex();
  int _currentId = 0;

  void _addChange(_Change ch) {
    if (_running) {
      _pendingChanges.add(ch);
    }
  }

  /// create a new progress
  ///
  /// `initialSnapshot` is the initial snapshot of the progress
  ///
  /// returns the progress id
  Future<int> createId(ProgressSnapshot initialSnapshot) async {
    if (!_running) {
      return -1;
    }

    await _idMutex.acquire();

    if (!_running) {
      return -1;
    }

    // get id
    int givenId = _currentId++;
    _idMutex.release();

    // push initial snapshot
    pushUpdate(givenId, initialSnapshot);
    _newSnapshots.add(givenId);

    return givenId;
  }

  /// removes a progress by its id
  ///
  /// `id` the id of the progress
  void removeId(int id) {
    // remove snapshot matching `id` from the map
    _addChange((map) => map.remove(id));
  }

  /// pushes a new progress snapshot to the given progress id
  void pushUpdate(int id, ProgressSnapshot snap) {
    // set the current value in the map
    _addChange((map) => map[id] = snap);
  }

  /// disposes of the resources
  Future<void> dispose() async {
    _running = false;
    await _pendingChanges.close();
  }
}

/// an extension of `ProgressRepository` (because it's not connected to its main functionality)
///
/// this extension creates a new progress from a stream of progress snapshots
extension StreamFeeder on ProgressRepository {
  Future<int> feed(Stream<ProgressSnapshot> snapshots) async {
    // we use a broadcast stream here since we use both snapshots.first
    // and snapshots.listen
    snapshots = snapshots.asBroadcastStream();

    int id = await createId(await snapshots.first);
    snapshots.listen((snapshot) => pushUpdate(id, snapshot));
    return id;
  }
}
