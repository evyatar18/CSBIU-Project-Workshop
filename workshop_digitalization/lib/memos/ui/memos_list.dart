import 'package:flutter/material.dart';
import 'package:workshop_digitalization/global/const.dart';

import '../memo.dart';
import 'memo_view.dart';

class MemoScaffold extends StatelessWidget {
  final MemoManager memoManager;

  MemoScaffold({
    @required this.memoManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () => _openCreate()),
    );
  }
}

///
/// Displays a `ListView` containing clickable cards of memos
///
class MemosListView extends StatefulWidget {
  final MemoManager memoManager;

  MemosListView({
    @required this.memoManager,
  });

  @override
  _MemosListViewState createState() => _MemosListViewState();
}

class _MemosListViewState extends State<MemosListView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.memoManager.memos,
      initialData: widget.memoManager.latestMemos,
      builder: (context, snapshot) {
        List<Memo> memos = snapshot.data;

        return Container(
          child: ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) =>
                MemoCard(memo: memos[index], manager: widget.memoManager),
          ),
        );
      },
    );
  }
}

class MemoCard extends StatelessWidget {
  final Memo memo;
  final MemoManager<Memo> manager;

  MemoCard({
    @required this.memo,
    @required this.manager,
  });

  void _openMemoPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoView(
          memo: this.memo,
          manager: manager,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _openMemoPage(context),
        child: ListTile(
          title: Text(memo.topic),
          subtitle: Text(
              "Created: ${dateDisplayFormat.format(memo.creationDate)} | Edited: ${dateDisplayFormat.format(memo.lastUpdate)}"),
        ),
      ),
    );
  }
}
