import 'dart:async';

import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// a simple widget which allows editing text and viewing its HTML rendering on the web
class WebHtmlEditor extends StatefulWidget {
  final String initialInput;
  final Stream<Completer<String>> inputRequests;

  WebHtmlEditor({
    @required this.initialInput,
    @required this.inputRequests,
  });

  @override
  _WebHtmlEditorState createState() => _WebHtmlEditorState();
}

class _WebHtmlEditorState extends State<WebHtmlEditor> {
  // on defaut, use the html viewer
  bool _usingHtmlViewer = true;

  TextEditingController _textController;
  StreamSubscription _requestsSubscription;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialInput);
    _requestsSubscription = widget.inputRequests.listen(_requestsHandler);
  }

  void _requestsHandler(Completer<String> completer) {
    completer.complete(_textController.text);
  }

  @override
  void dispose() {
    _requestsSubscription.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      IconButton(
        icon: Icon(_usingHtmlViewer ? Icons.edit : Icons.visibility),
        onPressed: _toggle,
      ),
      _usingHtmlViewer ? _buildHtmlViewer() : _buildTextEditor(),
    ]);
  }

  void _toggle() {
    setState(() => _usingHtmlViewer = !_usingHtmlViewer);
  }

  Widget _buildHtmlViewer() {
    return EasyWebView(
      height: 300,
      src: _textController.text,
      isHtml: true,
      convertToWidgets: false,
      onLoaded: () {},
    );
  }

  Widget _buildTextEditor() {
    return TextField(
      controller: _textController,
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );
  }
}
