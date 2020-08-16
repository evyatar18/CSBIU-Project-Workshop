import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html_editor/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/files/ui/file_view.dart';
import 'package:workshop_digitalization/platform/init.dart';

import '../memo.dart';
import '../memo_sender.dart';

class MemoView extends StatefulWidget {
  final Memo memo;
  final MemoManager<Memo> manager;
  final Function() onCancel;
  final List<String> recipients;

  MemoView({
    @required this.memo,
    @required this.manager,
    this.onCancel,
    this.recipients = const <String>[],
  });

  @override
  State<StatefulWidget> createState() => MemoViewState();
}

class MemoViewState extends State<MemoView> {
  GlobalKey<HtmlEditorState> keyTopic = GlobalKey();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _topicController = TextEditingController();

  /// filter only text requests which have not been completed
  Stream<Completer<String>> get _textRequests =>
      _textRequestsController.stream.where((event) => !event.isCompleted);

  StreamController<Completer<String>> _textRequestsController;

  Future<bool> _onWillPop() async {
    var ch = await _thereIsChanges();
    if (ch) {
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Do you want to exit without save?'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('No'),
                ),
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    if (widget.onCancel != null) {
                      widget.onCancel();
                    }
                  },
                  child: new Text('Yes'),
                ),
              ],
            ),
          )) ??
          false;
    }
    return true;
  }

  void initState() {
    super.initState();

    _topicController.text = widget.memo.topic;
    _textRequestsController = BehaviorSubject<Completer<String>>();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _textRequestsController.close();

    super.dispose();
  }

  void _reset() {
    setState(() {
      _topicController.text = widget.memo.topic;
    });
  }

  Future<String> _getText() {
    final req = Completer<String>();
    _textRequestsController.add(req);
    return req.future;
  }

  Future<bool> _thereIsChanges() async {
    final txt = await _getText();
    return (widget.memo.content != txt ||
        widget.memo.topic != _topicController.text);
  }

  void _save() async {
    final txt = await _getText();

    // update memo data
    setState(() {
      widget.memo.content = txt;
      widget.memo.topic = _topicController.text;
    });

    // save
    widget.manager.save(widget.memo);
  }

  bool _opening = false;
  void _openFiles() {
    if (_opening) return;

    _opening = true;
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text("Memo Files")),
            body: createFileContainerDisplayer(
              container: widget.memo.attachedFiles,
            ),
          ),
        ),
      );
    } catch (e) {
      print("error opening files view(memo_view.dart): $e");
    } finally {
      _opening = false;
    }
  }

  Widget bottomButtonSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            color: Colors.blueGrey,
            onPressed: _reset,
            child: Text("Reset", style: TextStyle(color: Colors.white)),
          ),
          FlatButton(
            color: Colors.blue,
            onPressed: _save,
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget appBarSection() {
    return AppBar(
      title: Text('Edit your Memo'),
      actions: <Widget>[
        FlatButton(
          onPressed: _openFiles,
          child: Icon(Icons.attach_file, color: Colors.white),
        ),
        FlatButton(
          onPressed: () =>
              openMemoEmail(memo: widget.memo, recipients: widget.recipients),
          child: Icon(Icons.mail, color: Colors.white),
        ),
      ],
    );
  }

  Widget subject() {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Subject: '),
          Expanded(
            child: TextField(
              controller: _topicController,
            ),
          )
        ],
      ),
    );
  }

  Widget dates() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
              'created at ${_dateFormat.format(widget.memo.creationDate)}'),
        ),
        if (widget.memo.lastUpdate != null)
          Expanded(
            child: Text(
              'updated at ${_dateFormat.format(widget.memo.lastUpdate)}',
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: appBarSection(),
        body: SingleChildScrollView(
          child: Card(
            child: Column(
              children: <Widget>[
                dates(),
                subject(),
                currentPlatform.htmlEditor(widget.memo.content, _textRequests),
                bottomButtonSection(),
              ],
            ),
          ),
        ),
        resizeToAvoidBottomPadding: false,
      ),
    );
  }
}
