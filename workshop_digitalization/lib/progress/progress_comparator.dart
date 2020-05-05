import 'progress.dart';
import 'progress_repo.dart';

/// Gives a value to snapshot according to current progress
/// in progress: 0
/// error: 1
/// complete: 2
int valueSnapshot(ProgressSnapshot snap) {
  if (snap.isInProgress) {
    return 0;
  }

  if (snap.failed) {
    return 1;
  }

  return 2;
}

///
/// Compares two snapshots s1, s2
/// first compares by _valueSnapshot
/// if their values are equal, compares by ids - the higher id is before the lower id
int defaultSnapshotComparator(
    IdentifiedProgressSnapshot s1, IdentifiedProgressSnapshot s2) {
  int res = valueSnapshot(s1) - valueSnapshot(s2);

  // prefer showing newer snapshots over old ones
  if (res == 0) {
    return -(s1.id - s2.id);
  }

  return res;
}
