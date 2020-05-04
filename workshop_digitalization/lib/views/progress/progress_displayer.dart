import 'package:flutter/material.dart';
import 'package:workshop_digitalization/views/progress/progress.dart';
import 'package:workshop_digitalization/views/progress/progress_bar.dart';
import 'package:workshop_digitalization/views/progress/progress_repo.dart';

class ProgressBarList extends StatelessWidget {
  final ProgressRepository repo;
  final Comparator<IdentifiedProgressSnapshot> comp;

  ProgressBarList(this.repo, {this.comp = _snapshotComparator});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IdentifiedProgressSnapshot>>(
      initialData: repo.latestSnapshots,
      stream: repo.snapshots,
      builder: (context, repoSnapshot) {
        final data = List<IdentifiedProgressSnapshot>.from(repoSnapshot.data);
        data.sort(comp);

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final currentSnapshot = data[index];

            return Row(
              children: <Widget>[
                Expanded(child: LinearProgressBar(snapshot: currentSnapshot)),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => repo.removeId(currentSnapshot.id),
                )
              ],
            );
          },
        );
      },
    );
  }
}

int _valueSnapshot(ProgressSnapshot snap) {
  if (snap.isInProgress) {
    return 0;
  }

  if (snap.failed) {
    return 1;
  }

  return 2;
}

int _snapshotComparator(
    IdentifiedProgressSnapshot s1, IdentifiedProgressSnapshot s2) {
  int res = _valueSnapshot(s1) - _valueSnapshot(s2);

  // prefer showing newer snapshots over old ones
  if (res == 0) {
    return -(s1.id - s2.id);
  }

  return res;
}

class ProgressScaffold extends StatefulWidget {
  final ProgressRepository repo;
  final Widget body;

  ProgressScaffold({@required this.repo, @required this.body});

  @override
  _ProgressScaffoldState createState() => _ProgressScaffoldState();
}

class _ProgressScaffoldState extends State<ProgressScaffold>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);

    widget.repo.newSnapshotListener.listen((i) async {
      try {
        _controller.stop();
      } catch (e) {}

      try {
        await _controller.forward();
        await Future.delayed(Duration(seconds: 1));
        await _controller.reverse();
      } catch (e) {}
    });

    _buttonAnimation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _animatedButton() {
    final button = Builder(
      builder: (context) {
        return FloatingActionButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          child: Icon(Icons.arrow_forward),
          backgroundColor: Colors.orangeAccent,
        );
      },
    );

    return SlideTransition(position: _buttonAnimation, child: button);
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(
            child: DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Ongoing Tasks",
                  style: Theme.of(context).textTheme.display1.apply(color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            width: double.infinity,
            height: 120,
          ),
          Expanded(child: ProgressBarList(widget.repo))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          widget.body,
          Align(alignment: Alignment.centerLeft, child: _animatedButton()),
        ],
      ),
      drawer: _buildDrawer(context),
    );
  }
}
