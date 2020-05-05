import 'package:flutter/material.dart';
import 'package:html_editor/html_editor.dart';

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
  GlobalKey<HtmlEditorState> keyEditor = GlobalKey();
  GlobalKey<HtmlEditorState> keyTopic = GlobalKey();

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
        title: Text('Edit your Memo'),
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
            child: Column(
              children: <Widget>[
                ListTile(
                    title: Row(
                  children: <Widget>[
                    Expanded(child: Text('Subject')),
                    Expanded(
                      child: TextField(
                        controller: _notesController,
                        onChanged: (text) {
                          widget.memo.topic = text;
                        },
                        cursorColor: Theme.of(context).canvasColor,
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                )),
                HtmlEditor(
                  hint: "Your text here...",
                  value: widget.memo.content,
                  key: keyEditor,
                  height: 400,
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          color: Colors.blueGrey,
                          onPressed: () {
                            setState(() {
                              //  keyEditor.currentState.setEmpty();
                              keyEditor.currentState.setText(widget.memo.content);
                            });
                          },
                          child: Text("Reset",
                              style: TextStyle(color: Colors.white)),
                        ),
                        FlatButton(
                          color: Colors.blue,
                          onPressed: () async {
                            final txt = await keyEditor.currentState.getText();
                            setState(() {
                              widget.memo.content = txt;
                            });
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
