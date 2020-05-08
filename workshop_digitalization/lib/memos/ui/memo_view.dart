import 'package:flutter/material.dart';
import 'package:html_editor/html_editor.dart';
import 'package:intl/intl.dart';

import '../memo.dart';

class MemoView extends StatefulWidget {
  final Memo memo;
  final MemoManager<Memo> manager;

  MemoView({
    @required this.memo,
    @required this.manager
  });

  @override
  State<StatefulWidget> createState() => MemoViewState();
}

class MemoViewState extends State<MemoView> {
  GlobalKey<HtmlEditorState> keyEditor = GlobalKey();
  GlobalKey<HtmlEditorState> keyTopic = GlobalKey();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _topicController = TextEditingController();

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
                  onPressed: () => Navigator.of(context).pop(true),
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
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      keyEditor.currentState.setText(widget.memo.content);
      _topicController.text = widget.memo.topic;
    });
  }

  Future<bool> _thereIsChanges() async {
    final txt = await keyEditor.currentState.getText();
    return (widget.memo.content != txt ||
        widget.memo.topic != _topicController.text);
  }

  void _save() async {
    final txt = await keyEditor.currentState.getText();

    // update memo data
    setState(() {
      widget.memo.content = txt;
      widget.memo.topic = _topicController.text;
    });

    // save
    widget.manager.save(widget.memo);
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
          onPressed: _reset,
          child: Icon(Icons.refresh),
        ),
        FlatButton(
          onPressed: _save,
          child: Icon(Icons.save),
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
                'creatad at ${_dateFormat.format(widget.memo.creationDate)}')),
        widget.memo.lastUpdate != null
            ? Expanded(
                child: Text(
                    'updated at ${_dateFormat.format(widget.memo.lastUpdate)}'))
            : Container()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: appBarSection(),
        body: Card(
          child: Column(
            children: <Widget>[
              dates(),
              subject(),
              HtmlEditor(
                hint: "Your text here...",
                value: widget.memo.content,
                key: keyEditor,
                height: 400,
                decoration: BoxDecoration(),
              ),
              bottomButtonSection(),
            ],
          ),
        ),
        resizeToAvoidBottomPadding: false,
      ),
    );
  }
}
