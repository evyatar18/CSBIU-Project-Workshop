
import 'package:flutter/material.dart';
import 'package:workshop_digitalization/models/memo.dart';

class MemoView extends StatelessWidget {
  Memo memo;
  MemoView( {
    this.memo,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(memo.topic)),
      body: Card(
        child: SingleChildScrollView(
          child:Container(
            child: Text(memo.content)
          )
        )
      
      ),
    );
  }
  
}
