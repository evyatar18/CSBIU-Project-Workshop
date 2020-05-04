import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/memo.dart';

class MemoView extends StatefulWidget {
  Memo memo;
  MemoView({
    this.memo,
  });

  @override
  State<StatefulWidget> createState() {
    return MemoViewState();
  }
}

class MemoViewState extends State<MemoView> {
  
  TextEditingController _notesController = new TextEditingController();
  void initState() {
    super.initState();
    _notesController.text = widget.memo.content;
  }

   @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var memo = widget.memo;
    return Scaffold(
      appBar: AppBar(
        title: Text(memo.topic),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.save),
            )
      ],),
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
          
          )
      )))),
    );
  }
}
