import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/firebase_roots/dynamic_root/setup.dart';
import 'package:workshop_digitalization/global/ui/circular_loader.dart';
import 'package:workshop_digitalization/global/ui/completely_centered.dart';
import 'package:workshop_digitalization/global/ui/dialogs.dart';
import 'package:workshop_digitalization/platform/init.dart';

import '../firebase_connection_bloc.dart';

/// the change database screen
class DynamicDBHandler extends StatelessWidget {
  final WidgetBuilder builder;

  DynamicDBHandler({@required this.builder, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseConnectionBloc>(
      create: (_) => FirebaseConnectionBloc(load: true),
      dispose: (_, value) => value.dispose(),
      builder: (context, child) {
        final bloc = Provider.of<FirebaseConnectionBloc>(context);

        if (bloc == null) {
          return LabeledCircularLoader(
            labels: ["Loading FirebaseConnectionBloc object"],
          );
        }

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
              return Container(
                padding: EdgeInsets.only(top: 50),
                child: SingleChildScrollView(
                  child: _buildChooser(context, bloc),
                ),
              );
            }
          },
        );
      },
    );
  }

  /// the screen which shows and prompts the user to provide with the firebase data (ie. `google-services.json` or the `firebase config for web`)
  Widget _buildChooser(BuildContext context, FirebaseConnectionBloc bloc) {
    return CompletelyCentered(
      children: [
        Text("Please copy ${currentPlatform.firebaseFilename}"),
        Text("to your clipboard"),
        Text("and then click the load database button"),
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
              final opts =
                  currentPlatform.parseFirebaseOptions(clipboardData.text);
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
          // show new clipboard values every 500ms
          stream: Stream.periodic(Duration(milliseconds: 500)).asyncMap(
            (_) async => (await Clipboard.getData("text/plain"))?.text,
          ),
          builder: (context, snapshot) {
            final message = snapshot.hasError
                ? "Error getting data from clipboard, maybe the permission is not turned on?"
                : snapshot.data ?? "(empty)";

            return Column(
              children: <Widget>[
                Text("Current Clipboard:"),
                SizedBox(height: 30),
                Text(message)
              ],
            );
          },
        )
      ],
    );
  }
}
