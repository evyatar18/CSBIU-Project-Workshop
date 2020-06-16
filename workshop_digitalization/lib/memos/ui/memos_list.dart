import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:workshop_digitalization/global/strings.dart';
import 'package:workshop_digitalization/memos/ui/memo_send_popup.dart';

import '../memo.dart';
import 'memo_view.dart';

class MemoScaffold extends StatelessWidget {
  final MemoManager memoManager;
  final _MemoOpener _opener;
  final List<String> memoEmailRecipients;

  MemoScaffold({
    @required this.memoManager,
    this.memoEmailRecipients = const [],
  }) : _opener = _MemoOpener(memoManager);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _opener.openNew(context, recipients: memoEmailRecipients),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: MemosListView(
        memoManager: memoManager,
        opener: _opener,
        memoEmailRecipients: memoEmailRecipients,
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
  final List<String> memoEmailRecipients;

  MemosListView({
    @required this.memoManager,
    @required this.opener,
    this.memoEmailRecipients,
  });

  @override
  _MemosListViewState createState() => _MemosListViewState();
}

class _MemosListViewState extends State<MemosListView> {
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
              emailRecipients: widget.memoEmailRecipients,
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
  final List<String> emailRecipients;

  MemoCard({
    @required this.memo,
    @required this.manager,
    @required this.memoOpener,
    this.emailRecipients,
  });

  void _openMemoPage(BuildContext context) =>
      memoOpener.openExisting(context, memo, recipients: emailRecipients);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _openMemoPage(context),
        child: ListTile(
          title: Text(memo.topic),
          subtitle: Text(
            "Created: ${writeDate(memo.creationDate)} | Edited: ${writeDate(memo.lastUpdate)}",
          ),
          trailing: Wrap(children: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => manager.delete(memo),
            ),
            if (emailRecipients != null)
              IconButton(
                icon: Icon(Icons.email),
                onPressed: () {
                  showMemoSendPopup(context, memo, emailRecipients);
                },
              )
          ]),
        ),
      ),
    );
  }
}

class _MemoOpener {
  bool _opening = false;
  MemoManager manager;

  _MemoOpener(this.manager);

  final _openMutex = Mutex();
  Future<bool> _tryOpening() async {
    if (_opening) return false;

    try {
      await _openMutex.acquire();
      if (_opening) {
        return false;
      }

      _opening = true;
      return true;
    } finally {
      _openMutex.release();
    }
  }

  Future<void> openNew(BuildContext context,
      {List<String> recipients = const <String>[]}) async {
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
            recipients: recipients,
          ),
        ),
      );
    } catch (e) {
      print("failed opening a new memo(memos_list.dart): $e");
    } finally {
      _opening = false;
    }
  }

  Future<void> openExisting(BuildContext context, Memo memo,
      {List<String> recipients = const <String>[]}) async {
    if (!(await _tryOpening())) return;

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemoView(
            memo: memo,
            manager: manager,
            recipients: recipients,
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
