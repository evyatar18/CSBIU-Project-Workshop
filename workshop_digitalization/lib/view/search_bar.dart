import 'package:flutter/material.dart';

typedef void OnSearch(String searchTerm);

class SearchBar extends StatefulWidget {

  OnSearch _onSearch;

  SearchBar(this._onSearch);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => widget._onSearch(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(Icons.search),
        TextField(controller: _controller)
      ],
    );
  }
}