import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/strings.dart';

import '../progress_repo.dart';
import 'progress_list_view.dart';

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
  StreamSubscription _newSnapshotSubscription;

  @override
  void initState() {
    super.initState();

    // initialize controller
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);

    // when a new snapshot was created
    _newSnapshotSubscription = widget.repo.newSnapshotListener.listen((i) async {
      try {
        _controller.stop();
      } catch (e) {}

      try {
        await _controller.forward();
        await Future.delayed(Duration(seconds: 1));
        await _controller.reverse();
      } catch (e) {}
    });

    // the popping button animation
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
    _newSnapshotSubscription.cancel();
    _controller.dispose();
  }

  Widget _animatedButton() {
    // the button itself
    final button = Builder(
      builder: (context) {
        return FloatingActionButton(
          heroTag: randomString(20),
          onPressed: () => Scaffold.of(context).openDrawer(),
          child: Icon(Icons.arrow_forward),
          backgroundColor: Colors.orangeAccent,
        );
      },
    );

    // animate the button
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
                  style: Theme.of(context)
                      .textTheme
                      .display1
                      .apply(color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            width: double.infinity,
            height: 120,
          ),
          Expanded(child: ProgressBarListView(widget.repo))
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
