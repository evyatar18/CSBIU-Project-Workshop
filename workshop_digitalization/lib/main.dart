import 'dart:async';

import 'package:flamingo/flamingo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:workshop_digitalization/auth/ui/authorization_checker.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/firebase_consts/dynamic_db/ui/db_data.dart';
import 'package:workshop_digitalization/menu/ui/home_page.dart';
import 'package:workshop_digitalization/platform/init.dart';

import 'settings/settings.dart';
import 'global/ui/circular_loader.dart';
import 'global/ui/completely_centered.dart';
import 'student_project/project/project.dart';
import 'student_project/student/student.dart';
import 'auth/ui/sign_out.dart';
import 'firebase_consts/dynamic_db/ui/change_db.dart';
import 'firebase_consts/firebase_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializePlatform();

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
                // we'll also start the root loader
                firebase.roots.listen();
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
    final students = firebase.activeRoot.studentManager;
    final projects = firebase.activeRoot.projectManager;

    return MultiProvider(
      providers: [
        Provider<StudentManager>.value(value: students),
        Provider<ProjectManager>.value(value: projects),
      ],
      child: MyHomePage(),
    );
  }

  Future<String> _getDefaultRootName(FirebaseInstance firebase) async {
    bool skippedOne = false;

    final rootsFuture = firebase.roots.rootStream
        // skip the first one if empty
        .skipWhile(
          (element) {
            if (skippedOne) {
              return false;
            }
            skippedOne = true;
            return element.isEmpty;
          },
        )
        .first
        // timeout after 5 seconds
        .timeout(Duration(seconds: 5));

    try {
      final rootNames = (await rootsFuture).map((root) => root.name).toList();
      return MyAppSettings.getDefaultRootName(rootNames);
    } on TimeoutException catch (e) {
      throw "Firebase timed out after: ${e.duration}";
    } catch (e) {
      rethrow;
    }
  }

  /// The widget which updates the view each time the root is changed
  Widget _buildRootUpdater(
    FirebaseInstance firebase,
    WidgetBuilder childBuilder,
  ) {
    // we use FutureBuilder to get a **default** root collection
    return FutureBuilder<String>(
      future: _getDefaultRootName(firebase),
      builder: (context, snapshot) {
        final auth = firebase.authenticator;

        if (snapshot.hasError) {
          return CompletelyCentered(
            children: [
              Text("Failed loading default root:"),
              Text(snapshot.error.toString()),
              SignOutButton(authenticator: auth),
            ],
          );
        }

        if (!snapshot.hasData) {
          return LabeledCircularLoader(
            labels: ["Loading default root"],
            children: <Widget>[
              ChangeDBButton(),
              SignOutButton(authenticator: auth),
            ],
          );
        }

        final defaultRoot = snapshot.data;
        print("Default root: $defaultRoot");

        // we use a ValueChangeObserver to change the root when it is changed in the settings
        return ValueChangeObserver<String>(
          cacheKey: MyAppSettings.firebaseRootName,
          defaultValue: snapshot.data,
          builder: (context, versionName, onChangeRootSetting) {
            // holds the current root reference
            FirebaseRoot current;
            // after changed a root in the settings, get the corresponding FirebaseRoot object
            // and use it as the current firebase root
            return StreamBuilder<void>(
              stream: firebase.roots.rootStream
                  // find and return the root with the current name
                  .map(
                    (roots) => roots.firstWhere(
                      (root) => root.name == versionName,
                      orElse: () => null,
                    ),
                  )
                  // if there was an update to another root, just ignore
                  // only if there's no current root, show the event
                  .skipWhile((root) => root == current && current != null)
                  .asyncMap(
                (root) {
                  // set the current root reference
                  current = root;
                  return root == null
                      ? Future<void>.value()
                      : firebase.useRoot(root);
                },
              ),
              builder: (context, snapshot) {
                final routeCreator = [
                  SizedBox(height: 20),
                  Text("You may create the route if it doesn't exist"),
                  RaisedButton(
                    onPressed: () => firebase.roots.getRoot(versionName),
                    child: Text("Create Root"),
                  ),
                  Text("Or you can use another available root"),
                  StreamBuilder<String>(
                    stream: firebase.roots.rootStream
                        .where((event) => event != null)
                        .map(
                          (event) => MyAppSettings.getDefaultRootName(
                            event
                                .where((element) =>
                                    element.name != versionName &&
                                    element.name != null)
                                .map((e) => e.name)
                                .toList(),
                          ),
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          "Error loading default root: ${snapshot.error}",
                        );
                      }
                      if (!snapshot.hasData) {
                        return LabeledCircularLoader(
                          labels: ["Loading default root..."],
                        );
                      }
                      final defaultRoot = snapshot.data;
                      return RaisedButton(
                        onPressed: () {
                          MyAppSettings.setRoot(defaultRoot);
                          onChangeRootSetting(defaultRoot);
                        },
                        child: Text("Change Root (to $defaultRoot)"),
                      );
                    },
                  ),
                ];

                if (snapshot.hasError) {
                  return CompletelyCentered(children: [
                    Text(
                      "Failed getting and using the firebase root $versionName",
                    ),
                    Text(snapshot.error.toString()),
                    ChangeDBButton(),
                    ...routeCreator,
                  ]);
                }

                if (!snapshot.hasData) {
                  return LabeledCircularLoader(
                    labels: ["Getting root `$versionName` from firebase..."],
                    children: <Widget>[...routeCreator],
                  );
                }

                // configure flamingo to use this instance of firebase
                Flamingo.configure(
                  firestore: firebase.firestore,
                  storage: firebase.storage,
                  root: firebase.activeRoot.root.reference,
                );

                return Builder(builder: childBuilder);
              },
            );
          },
        );
      },
    );
  }
}
