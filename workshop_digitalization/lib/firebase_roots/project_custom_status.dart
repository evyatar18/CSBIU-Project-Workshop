import 'firebase_root.dart';

/// an extension on `FirebaseRoot` which allows getting and settting the project statuses property
extension ProjectStatuses on FirebaseRoot {
  List<String> get statuses => (this["project-statuses"] ?? []).cast<String>();
  set statuses(List<String> statuses) => this["project-statuses"] = statuses;
}