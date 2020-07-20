import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/auth/ui/authorization_checker.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/ui/db_data.dart';
import 'package:workshop_digitalization/menu/ui/home_page.dart';

import 'settings/settings.dart';
import 'global/ui/circular_loader.dart';
import 'global/ui/completely_centered.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // use default shared preferences provider
  await Settings.init();

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Digitalization',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: DynamicDBHandler(
          builder: (context) {
            final firebase = Provider.of<FirebaseInstance>(context);
            return Authorizer(
              builder: (context, user) {
                // now the current user is authorized, we can show the root updater
                return _buildRootUpdater(firebase, _mainBodyBuilder);
              },
            );
          },
        ),
      ),
    );
  }

  /// Builds the students and projects providers
  /// Then builds the actual application
  Widget _mainBodyBuilder(BuildContext context) {
    final firebase = Provider.of<FirebaseInstance>(context);
    final students = firebase.root.studentManager;
    final projects = firebase.root.projectManager;

    return MultiProvider(
      providers: [
        Provider.value(value: students),
        Provider.value(value: projects),
      ],
      child: MyHomePage(),
    );
  }

  /// The widget which updates the view each time the root is changed
  Widget _buildRootUpdater(
    FirebaseInstance firebase,
    WidgetBuilder childBuilder,
  ) {
    // we use FutureBuilder to get a **default** root collection
    return FutureBuilder<String>(
      future: () async {
        final rootsFuture = firebase.roots.rootStream.first;
        final roots = firebase.roots.roots;
        final rootNames = (roots ?? await rootsFuture).map((root) => root.name).toList();

        return MyAppSettings.getDefaultRootName(rootNames);
      }(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CompletelyCentered(
            children: [
              Text("Failed loading default root:"),
              Text(snapshot.error.toString()),
            ],
          );
        }

        if (!snapshot.hasData) {
          return LabeledCircularLoader(
            labels: ["Loading default root"],
          );
        }

        final firebase = Provider.of<FirebaseInstance>(context);

        // we use a ValueChangeObserver to change the root when it is changed in the settings
        return ValueChangeObserver(
          cacheKey: MyAppSettings.firebaseRootName,
          defaultValue: snapshot.data,
          builder: (context, versionName, _) {
            // after changed a root in the settings, get the corresponding FirebaseRoot object
            // and use it as the current firebase root
            return FutureBuilder<void>(
              future:
                  firebase.roots.getRoot(versionName).then(firebase.useRoot),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return CompletelyCentered(children: [
                    Text(
                      "Failed getting and using the firebase root $versionName",
                    ),
                    Text(snapshot.error.toString()),
                  ]);
                }

                if (!snapshot.hasData) {
                  return LabeledCircularLoader(
                    labels: ["Getting root `$versionName` from firebase..."],
                  );
                }

                return Builder(builder: childBuilder);
              },
            );
          },
        );
      },
    );
  }
}
