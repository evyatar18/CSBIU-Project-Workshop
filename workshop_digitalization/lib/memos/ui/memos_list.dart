import 'package:flutter/material.dart';

import '../memo.dart';
import 'memo_view.dart';

///
/// Displays a `ListView` containing clickable cards of memos
class MemosListView extends StatefulWidget {
  final List<Memo> memos;
  MemosListView({
    @required this.memos,
  });

  @override
  _MemosListViewState createState() => _MemosListViewState();
}

class _MemosListViewState extends State<MemosListView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: widget.memos.length,
        itemBuilder: (context, index) => MemoCard(memo: widget.memos[index]),
      ),
    );
  }
}

class MemoCard extends StatelessWidget {
  final Memo memo;
  MemoCard({
    @required this.memo,
  });

  void _openMemoPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MemoView(memo: this.memo)));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _openMemoPage(context),
        child: ListTile(
          title: Text(memo.topic),
          subtitle: Text("Created: ${memo.creationDate} | Edited: ${memo.lastUpdate}"),
        ),
      ),
    );
  }
}
