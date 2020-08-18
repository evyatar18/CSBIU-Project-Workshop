import 'package:firebase_core/firebase_core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/settings/settings.dart';

import 'setup.dart';

/// this BloC allows changing the currently used `FirebaseInstance`
class FirebaseConnectionBloc {
  final _controller = ReplaySubject<FirebaseInstance>();
  Stream<FirebaseInstance> get instances => _controller.stream;

  /// construct a new bloc
  ///
  /// `load` whether to load the connection details from the application settings
  ///
  /// `saveSettings` whether to save settings in the application settings
  FirebaseConnectionBloc({bool load = false, bool saveSettings = true}) {
    if (load) {
      loadSettings();
    }

    if (saveSettings) {
      instances.listen(_settingsSaver);
    }
  }

  /// saves the settings of the given firebase instance into the application settings
  Future<void> _settingsSaver(FirebaseInstance firebase) async {
    if (firebase == null) {
      MyAppSettings.setFirebaseOptions(null);
      return;
    }

    final opts = await firebase.app.options;
    MyAppSettings.setFirebaseOptions(opts.asMap);
  }

  /// loads the firebase instance from the current settings (if it's available in the settings)
  Future<void> loadSettings() {
    final opts = MyAppSettings.getFirebaseOptions();

    try {
      if (opts != null) {
        return useInstance(FirebaseOptions.from(opts));
      } else {
        return Future.sync(() => null);
      }
    } catch (e, trace) {
      _controller.addError(e, trace);
      rethrow;
    }
  }

  /// change the currently used `FirebaseInstance` instance using the given options
  Future<void> useInstance(FirebaseOptions opts) async {
    try {
      final instance = await initializeApp(opts);
      _controller.sink.add(instance);
    } catch (e, trace) {
      _controller.sink.addError(e, trace);
    }
  }

  /// removes the currently used `FirebaseInstance` (used when changing a database)
  void clearInstance() {
    _controller.sink.add(null);
  }

  /// disposes resources
  Future<void> dispose() => _controller.close();
}
