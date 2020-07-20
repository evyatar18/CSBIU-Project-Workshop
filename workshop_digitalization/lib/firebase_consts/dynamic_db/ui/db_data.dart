import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/firebase_options_reader.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/settings/settings.dart';

class FirebaseConnectionBloc {
  final _controller = StreamController<FirebaseInstance>();
  Stream<FirebaseInstance> get instances => _controller.stream;

  FirebaseConnectionBloc({bool load = false}) {
    if (load) {
      loadSettings();
    }
  }

  Future<void> loadSettings() {
    final opts = MyAppSettings.getFirebaseOptions();

    if (opts != null) {
      return useInstance(
        FirebaseOptions.from(MyAppSettings.getFirebaseOptions()),
      );
    } else {
      return Future.sync(() => null);
    }
  }

  Future<void> useInstance(FirebaseOptions opts) async {
    try {
      final instance = await initializeApp(opts);
      _controller.sink.add(instance);

      MyAppSettings.setFirebaseOptions(opts.asMap);
    } catch (e, trace) {
      _controller.sink.addError(e, trace);
    }
  }

  void clearInstance() {
    _controller.sink.add(null);
  }

  Future<void> dispose() => _controller.close();
}

class DynamicDBHandler extends StatelessWidget {
  final WidgetBuilder builder;

  DynamicDBHandler({@required this.builder, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseConnectionBloc>(
      create: (_) => FirebaseConnectionBloc(load: true),
      builder: (context, child) {
        final bloc = Provider.of<FirebaseConnectionBloc>(context);

        return StreamBuilder<FirebaseInstance>(
          stream: bloc.instances,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return CompletelyCentered(children: [
                Text("An error occurred when connecting to firebase:"),
                Text(snapshot.error.toString()),
                SizedBox(height: 10),
                RaisedButton(
                  child: Text("Continue"),
                  onPressed: bloc.clearInstance,
                )
              ]);
            }

            if (snapshot.hasData) {
              return Provider.value(
                value: snapshot.data,
                builder: (context, _) => builder(context),
              );
            } else {
              return SingleChildScrollView(
                child: _buildChooser(context, bloc),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildChooser(BuildContext context, FirebaseConnectionBloc bloc) {
    return CompletelyCentered(
      children: [
        Text("Please copy `google-services.json`"),
        Text(" to your clipboard"),
        Text(" and then click the load database button"),
        RaisedButton(
          child: Text("Load"),
          onPressed: () async {
            ClipboardData clipboardData;
            try {
              clipboardData = await Clipboard.getData("text/plain");
            } catch (e) {
              showErrorDialog(
                context,
                title: "Error while getting text from clipboard\n"
                    "Make sure the clipboard permission is turned on",
                error: e.toString(),
              );
            }

            try {
              final opts = await generateOptions(clipboardData.text);
              bloc.useInstance(opts);
            } catch (e) {
              showErrorDialog(
                context,
                title: "Error while parsing options",
                error: e.toString(),
              );
            }
          },
        ),
        StreamBuilder(
          stream: Stream.periodic(Duration(microseconds: 500)).asyncMap(
            (_) async => (await Clipboard.getData("text/plain"))?.text,
          ),
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  Text("Current Clipboard:"),
                  SizedBox(height: 20),
                  Text(snapshot.data ?? "(empty)")
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
