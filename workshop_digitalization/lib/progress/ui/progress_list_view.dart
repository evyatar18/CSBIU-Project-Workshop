import 'package:flutter/material.dart';

import '../progress_comparator.dart';
import '../progress_repo.dart';
import 'progress_bar.dart';

class ProgressBarListView extends StatelessWidget {
  final ProgressRepository repo;
  final Comparator<IdentifiedProgressSnapshot> comp;

  ProgressBarListView(this.repo, {this.comp = defaultSnapshotComparator});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IdentifiedProgressSnapshot>>(
      initialData: repo.latestSnapshots,
      stream: repo.snapshots,
      builder: (context, repoSnapshot) {
        // get data and sort using the comparator
        final data = List<IdentifiedProgressSnapshot>.from(repoSnapshot.data);
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
