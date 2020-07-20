import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/firebase_options_reader.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';

class FirebaseConnectionBloc {
  final _controller = StreamController<FirebaseInstance>();
  Stream<FirebaseInstance> instances;

  Future<void> useInstance(FirebaseOptions opts) async {
    try {
      final instance = await initializeApp(opts);
      _controller.sink.add(instance);
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
      create: (_) => FirebaseConnectionBloc(),
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
              return CompletelyCentered(
                children: [
                  Text(
                    "Please copy `google-services.json` to your clipboard"
                    " and then click the load database button",
                  ),
                  RaisedButton(
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
                ],
              );
            }
          },
        );
      },
    );
  }
}
