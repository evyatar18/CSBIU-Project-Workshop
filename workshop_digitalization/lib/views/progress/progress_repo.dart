import 'dart:async';

import 'package:mutex/mutex.dart';
import 'package:workshop_digitalization/models/disposable.dart';
import 'package:workshop_digitalization/views/progress/progress.dart';

class IdentifiedProgressSnapshot implements ProgressSnapshot {
  final int id;
  ProgressSnapshot _snapshot;

  @override
  bool get failed => _snapshot.failed;

  @override
  bool get isInProgress => _snapshot.isInProgress;

  @override
  bool get isSuccess => _snapshot.isSuccess;

  @override
  String get message => _snapshot.message;

  @override
  double get progress => _snapshot.progress;

  @override
  String get taskName => _snapshot.taskName;

  IdentifiedProgressSnapshot(this.id, this._snapshot);
}

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

      yield _current = cpy.entries.map((entry) => IdentifiedProgressSnapshot(entry.key, entry.value)).toList();
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

  void removeId(int id) {
    // remove snapshot matching `id` from the map
    _addChange((map) => map.remove(id));
  }

  void pushUpdate(int id, ProgressSnapshot snap) {
    // set the current value in the map
    _addChange((map) => map[id] = snap);
  }

  Future<void> dispose() async {
    _running = false;
    await _pendingChanges.close();
    await snapshots.last;
  }
}

Future<int> feedStream(ProgressRepository repo, Stream<ProgressSnapshot> snapshots) async {
  snapshots = snapshots.asBroadcastStream();

  int id = await repo.createId(await snapshots.first);
  snapshots.listen((snapshot) => repo.pushUpdate(id, snapshot));
  return id;
}