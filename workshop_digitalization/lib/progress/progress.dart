class ProgressSnapshot {
  final String taskName;
  final String message;
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
