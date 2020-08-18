import 'package:firebase_core/firebase_core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:workshop_digitalization/settings/settings.dart';

import 'setup.dart';

class FirebaseConnectionBloc {
  final _controller = ReplaySubject<FirebaseInstance>();
  Stream<FirebaseInstance> get instances => _controller.stream;

  FirebaseConnectionBloc({bool load = false, bool saveSettings = true}) {
    if (load) {
      loadSettings();
    }

    if (saveSettings) {
      instances.listen(_settingsSaver);
    }
  }

  Future<void> _settingsSaver(FirebaseInstance firebase) async {
    if (firebase == null) {
      MyAppSettings.setFirebaseOptions(null);
      return;
    }

    final opts = await firebase.app.options;
    MyAppSettings.setFirebaseOptions(opts.asMap);
  }

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
