import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/views/progress/progress.dart';

class LinearProgressBar extends StatelessWidget {
  final ProgressSnapshot snapshot;

  LinearProgressBar({@required this.snapshot});

  Widget _statusBar(TextStyle baseFont, int percents) {
    return Align(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(snapshot.taskName, style: baseFont.apply(fontSizeDelta: 2)),
            Text("$percents%", style: baseFont.apply(fontSizeDelta: 1)),
          ]),
      alignment: Alignment.bottomLeft,
    );
  }

  Widget _buildWidget() {
    final color = snapshot.failed
        ? Colors.red
        : (snapshot.progress >= 1.0 ? Colors.green : Colors.orange[500]);

    final percents = (snapshot.progress * 100).toInt();

    return Builder(builder: (context) {
      final baseFont = Theme.of(context).textTheme.body1;

      return Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
                child: LinearProgressIndicator(
                  value: snapshot.progress,
                  backgroundColor: Colors.grey[400],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: _statusBar(baseFont, percents),
              )
            ],
          ),
          SizedBox(height: 5),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              snapshot.message,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(fontSizeDelta: 1, fontWeightDelta: 2),
            ),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: _buildWidget(),
    );
  }
}

class MultipleProgressSnapshotIndicators extends StatelessWidget {
  final Iterable<ProgressSnapshot> snapshots;

  MultipleProgressSnapshotIndicators({@required this.snapshots});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: snapshots
          .map(
              (snapshot) => LinearProgressBar(snapshot: snapshot))
          .toList(),
    );
  }
}

class UpdatingSnapshots extends StatelessWidget {
  final Stream<Iterable<ProgressSnapshot>> snapshots;
  UpdatingSnapshots({@required this.snapshots});

  UpdatingSnapshots.fromStreams(
      Iterable<Stream<ProgressSnapshot>> progressStreams)
      : snapshots = CombineLatestStream.list(progressStreams);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Iterable<ProgressSnapshot>>(
      stream: snapshots,
      initialData: <ProgressSnapshot>[],
      builder: (context, snap) =>
          MultipleProgressSnapshotIndicators(snapshots: snap.data),
    );
  }
}

class UpdatingSnapshotsDialog extends StatelessWidget {
  final Stream<List<ProgressSnapshot>> sortedSnapshots;
  final String title;

  UpdatingSnapshotsDialog(
      {@required Stream<List<ProgressSnapshot>> snapshots,
      this.title = "snapshots"})
      : sortedSnapshots = snapshots.map((snapshots) {
          snapshots = List.of(snapshots);
          snapshots.sort(_sorter());
          return snapshots;
        });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            this.title.toUpperCase(),
            style: Theme.of(context).textTheme.display1.apply(
                  color: Colors.black,
                  fontWeightDelta: 1,
                ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: UpdatingSnapshots(
                snapshots: sortedSnapshots,
              ),
            ),
          )
        ],
      ),
    );
  }

  static Comparator<ProgressSnapshot> _sorter() {
    int snapshotToValue(ProgressSnapshot snap) {
      // make sure those `in progress` are on the top
      if (snap.isInProgress) {
        return 0;
      }

      // after that the `failed`
      if (snap.failed) {
        return 1;
      }

      // then the `success`
      if (snap.isSuccess) {
        return 2;
      }

      return 3;
    }

    return (snap1, snap2) {
      return snapshotToValue(snap1) - snapshotToValue(snap2);
    };
  }
}

void showUpdatingSnapshotsDialog(
    BuildContext context, Iterable<Stream<ProgressSnapshot>> snapshots) {
  final combinedStream =
      CombineLatestStream.list(snapshots).asBroadcastStream();

  final subscription = <StreamSubscription<List<ProgressSnapshot>>>[];

  subscription.add(combinedStream.listen((snapshots) async {
    subscription[0].pause();

    // if complete
    if (snapshots.every((snap) => !snap.isInProgress)) {
      // cancel subscription
      subscription[0].cancel();
    } else {
      subscription[0].resume();
    }
  }));

  showDialog(
    context: context,
    child: UpdatingSnapshotsDialog(snapshots: combinedStream),
  );
}

Stream<ProgressSnapshot> createDummyProgressStream(String name) async* {
  double progress = 0;
  bool failed = false;

  ProgressSnapshot createReport() {
    String message = failed
        ? "failed progress"
        : (progress >= 1.0 ? "complete" : "in progress...");

    return ProgressSnapshot(name, message, progress, failed: failed);
  }

  final rand = Random();
  do {
    progress += rand.nextDouble() * .05;
    progress = min(1, progress);

    if (rand.nextDouble() < 0.01) {
      failed = true;
    }

    yield createReport();

    await Future.delayed(Duration(milliseconds: 500));
  } while (progress < 1.0 && !failed);
}
