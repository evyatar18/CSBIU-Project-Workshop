/// A snapshot of progress
class ProgressSnapshot {
  final String taskName;
  final String message;

  /// a value between 0 and 1 indicating how much progress has been made
  final double progress;
  final bool failed;

  bool get isSuccess => progress >= 1.0 && !failed;
  bool get isInProgress => progress < 1.0 && !failed;

  /// `progress` is a number from 0 to 1 indicating how much progress from the total
  /// progress has been done
  /// `taskName` is the name of the task
  /// `message` is a message indicating the progress
  /// `failed` is whether this task failed
  ProgressSnapshot(this.taskName, this.message, this.progress,
      {this.failed = false});
}

/// a progress snapshot implementation with an id
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
