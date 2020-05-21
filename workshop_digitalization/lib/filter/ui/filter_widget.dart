import 'package:flutter/material.dart';

abstract class DisplayedFilter implements Widget {
  dynamic get initialValue;

  // returns an error string when error should be displayed
  String Function(dynamic value) get onChange;
}

class TextFilter extends StatefulWidget {
  final dynamic initialValue;
  final String Function(dynamic value) onChange;

  TextFilter({this.initialValue = "", this.onChange});

  @override
  _TextFilterState createState() => _TextFilterState();
}

class _TextFilterState extends State<TextFilter> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);

    _controller.addListener(() {
      widget.onChange(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}

class SelectionFilter extends StatefulWidget implements DisplayedFilter {
  final dynamic initialValue;
  final String Function(dynamic value) onChange;
  final Map<dynamic, String> values;

  SelectionFilter({
    this.onChange,
    @required this.initialValue,
    // real value to display name map
    @required this.values,
  });

  @override
  _SelectionFilterState createState() => _SelectionFilterState();
}

class _SelectionFilterState extends State<SelectionFilter> {
  dynamic _value;
  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _onChanged(dynamic value) {
    setState(() => _value = value);
    widget.onChange(value);
  }

  DropdownMenuItem _build(dynamic value, String name) {
    double verticalPadding = 5;
    double horiziontalPadding = 1.6180327868852 * verticalPadding;
    return DropdownMenuItem(
      value: value,
      child: Padding(
        // uses golden ratio ()
        padding: EdgeInsets.symmetric(
          horizontal: horiziontalPadding,
          vertical: verticalPadding,
        ),
        child: Text(name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons =
        widget.values.entries.map((e) => _build(e.key, e.value)).toList();
    return DropdownButton(
      value: _value,
      items: buttons,
      onChanged: _onChanged,
    );
  }
}

String Function(dynamic) _makeOnChange<T>(void Function(T) onChange) {
  return (item) {
    try {
      onChange(item as T);
    } catch (e) {
      return e.toString();
    }

    return null;
  };
}

Widget textFilterBuilder(
    dynamic _, String initialValue, void Function(String) onChange) {
  return TextFilter(
    initialValue: initialValue ?? "",
    onChange: _makeOnChange<String>(onChange),
  );
}

Widget selectionFilterBuilder<T>(
    Map<T, String> values, T initialValue, void Function(T) onChange) {
  return SelectionFilter(
    initialValue: initialValue ?? values.keys.first,
    values: values,
    onChange: _makeOnChange<T>(onChange),
  );
}
