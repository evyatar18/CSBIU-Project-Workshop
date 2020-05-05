import 'package:flutter/material.dart';

import '../memo.dart';

class MemoView extends StatefulWidget {
  final Memo memo;
  MemoView({
    this.memo,
  });

  @override
  State<StatefulWidget> createState() => MemoViewState();
}

class MemoViewState extends State<MemoView> {
  final _notesController = TextEditingController();
  void initState() {
    super.initState();
    _notesController.text = widget.memo.content;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    // TODO:: add save logic

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memo.topic),
        actions: <Widget>[
          FlatButton(
            onPressed: _save,
            child: Icon(Icons.save),
          )
        ],
      ),
      body: Card(
        child: SingleChildScrollView(
          child: Container(
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _notesController,
              cursorColor: Theme.of(context).canvasColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
