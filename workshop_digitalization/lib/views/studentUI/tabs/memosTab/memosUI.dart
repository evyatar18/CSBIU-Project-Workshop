import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/memo.dart';
import 'package:workshop_digitalization/views/studentUI/tabs/memosTab/memoView.dart';

class MemoList extends StatefulWidget {
  List<Memo> memos;
  MemoList({this.memos});

  @override
  _MemoListState createState() => _MemoListState();
}

class _MemoListState extends State<MemoList> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          children: List.generate(widget.memos.length, (index) {
        return new MemoContainer(memo: widget.memos[index]);
      })),
    );
  }
}

class MemoContainer extends StatelessWidget {
  Memo memo;
  MemoContainer({
    this.memo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            onTap: ()=>{Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MemoView(memo: this.memo)))},
            child: ListTile(
      title: Text(memo.topic),
      subtitle: Text(memo.creationDate.toString()),
    )));
  }
}
