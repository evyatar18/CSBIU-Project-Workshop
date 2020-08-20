import 'package:package_info/package_info.dart';
import 'package:workshop_digitalization/platform/android/android.dart';
import 'package:workshop_digitalization/platform/platform.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:workshop_digitalization/platform/web/web.dart';

PlatformSpecific _currentPlatform;
PlatformSpecific get currentPlatform => _currentPlatform;

/// initializes the `currentPlatform` variable
Future<void> initializePlatform() async {
  if (kIsWeb) {
    _currentPlatform = WebPlatform();
    return;
  }

  if (Platform.isAndroid) {
    _currentPlatform = AndroidPlatform(await PackageInfo.fromPlatform());
    return;
  }

  throw UnsupportedError("Current operating system: "
      "${Platform.operatingSystem} is not supported.");
}