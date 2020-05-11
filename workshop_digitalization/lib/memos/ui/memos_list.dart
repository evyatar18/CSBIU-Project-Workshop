import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:workshop_digitalization/global/const.dart';

import '../memo.dart';
import 'memo_view.dart';

class MemoScaffold extends StatelessWidget {
  final MemoManager memoManager;
  final _MemoOpener _opener;

  MemoScaffold({
    @required this.memoManager,
  }) : _opener = _MemoOpener(memoManager);

  void _openCreateMemo(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateMemo(context),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: MemosListView(
        memoManager: memoManager,
        opener: _opener,
      ),
    );
  }
}

///
/// Displays a `ListView` containing clickable cards of memos
///
class MemosListView extends StatefulWidget {
  final MemoManager memoManager;
  final _MemoOpener opener;

  MemosListView({@required this.memoManager, @required this.opener});

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
            itemBuilder: (context, index) => MemoCard(
              memo: memos[index],
              manager: widget.memoManager,
              memoOpener: widget.opener,
            ),
          ),
        );
      },
    );
  }
}

class MemoCard extends StatelessWidget {
  final Memo memo;
  final MemoManager<Memo> manager;
  final _MemoOpener memoOpener;

  MemoCard(
      {@required this.memo, @required this.manager, @required this.memoOpener});

  void _openMemoPage(BuildContext context) =>
      memoOpener.openExisting(context, memo);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _openMemoPage(context),
        child: ListTile(
          title: Text(memo.topic),
          subtitle: Text(
            "Created: ${dateDisplayFormat.format(memo.creationDate)} | Edited: ${dateDisplayFormat.format(memo.lastUpdate)}",
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => manager.delete(memo),
          ),
        ),
      ),
    );
  }
}


class _MemoOpener {
  bool _opening = false;
  MemoManager manager;

  _MemoOpener(MemoManager manager);

  Mutex _openMutex;
  Future<bool> _tryOpening() async {
    if (_opening) return false;

    try {
      await _openMutex.acquire();
      if (_opening) {
        return false;
      }

      _opening = true;
    } finally {
      _openMutex.release();
    }
  }

  Future<void> openNew(BuildContext context) async {
    if (!(await _tryOpening())) return;

    try {
      Memo m = await manager.createEmpty();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemoView(
            memo: m,
            manager: manager,
            onCancel: () => manager.delete(m),
          ),
        ),
      );
    } catch (e) {
      print("failed opening a new memo(memos_list.dart): $e");
    } finally {
      _opening = false;
    }
  }

  Future<void> openExisting(BuildContext context, Memo memo) async {
    if (!(await _tryOpening())) return;

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemoView(
            memo: memo,
            manager: manager,
          ),
        ),
      );
    } catch (e) {
      print("failed opening an existing memo(memos_list.dart): $e");
    } finally {
      _opening = false;
    }
  }
}
