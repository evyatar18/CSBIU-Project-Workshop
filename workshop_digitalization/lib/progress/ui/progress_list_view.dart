import 'package:flutter/material.dart';

import '../progress.dart';
import '../progress_comparator.dart';
import '../progress_repo.dart';
import 'progress_bar.dart';

/// this is a list view which shows all the ongoing progresses of a given progress repository
class ProgressBarListView extends StatelessWidget {
  final ProgressRepository repo;
  final Comparator<IdentifiedProgressSnapshot> comp;

  /// `repo` is a `ProgressRepository` containing ongoing progresses
  ///
  /// `comp` is a comparator used to order the progresses in the listview
  ProgressBarListView(this.repo, {this.comp = defaultSnapshotComparator});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IdentifiedProgressSnapshot>>(
      initialData: repo.latestSnapshots,
      stream: repo.snapshots,
      builder: (context, repoSnapshot) {
        // get data and sort using the comparator
        final data = List<IdentifiedProgressSnapshot>.of(repoSnapshot.data, growable: false);
        data.sort(comp);

        // build list view
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final snapshot = data[index];

            return Row(
              children: <Widget>[
                Expanded(child: LinearProgressBar(snapshot: snapshot)),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => repo.removeId(snapshot.id),
                )
              ],
            );
          },
        );
      },
    );
  }
}
