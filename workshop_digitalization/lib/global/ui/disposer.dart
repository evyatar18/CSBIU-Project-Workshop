import 'package:flutter/material.dart';
import '../disposable.dart';

class Disposer<T extends Disposable> extends StatefulWidget {
  final T Function() create;
  final Widget Function(BuildContext context, T object) builder;
  final void Function(T object) onDispose;

  Disposer({@required this.create, @required this.builder, this.onDispose});

  @override
  _DisposerState<T> createState() => _DisposerState<T>();
}

class _DisposerState<T extends Disposable> extends State<Disposer<T>> {

  T object;

  @override
  void dispose() {
    super.dispose();

    try { widget.onDispose(object);}
    catch (e) { print(e); }

    object.dispose();
  }

  @override
  void initState() {
    super.initState();
    object = widget.create();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, object);
  }
}
