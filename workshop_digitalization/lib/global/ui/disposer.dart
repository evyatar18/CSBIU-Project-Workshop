import 'package:flutter/material.dart';
import '../disposable.dart';

class Disposer<T extends Disposable> extends StatefulWidget {
  final T Function() create;
  final Future<T> Function() createInFuture;
  final Widget Function(BuildContext context, T object) builder;
  final void Function(T object) onDispose;

  Disposer({
    this.create,
    this.createInFuture,
    @required this.builder,
    this.onDispose,
  }) : assert(create != null || createInFuture != null);

  @override
  _DisposerState<T> createState() => _DisposerState<T>();
}

class _DisposerState<T extends Disposable> extends State<Disposer<T>> {
  Future<T> _objectFuture;
  T _object;

  void _disposeObject(T object) {
    try {
      widget.onDispose?.call(object);
    } catch (e) {
      print(e);
    }

    object.dispose();
  }

  @override
  void dispose() {
    super.dispose();

    if (_object == null) {
      _objectFuture.then(_disposeObject);
      return;
    }

    _disposeObject(_object);
  }

  @override
  void initState() {
    super.initState();

    if (widget.createInFuture != null) {
      _objectFuture = widget.createInFuture();
    } else {
      _objectFuture = Future.value(widget.create());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _objectFuture,
      builder: (context, object) => object.data == null
          ? Text("loading...")
          : widget.builder(context, object.data),
    );
  }
}
