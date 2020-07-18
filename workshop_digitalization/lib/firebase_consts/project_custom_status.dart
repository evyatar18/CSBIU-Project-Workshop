import 'package:workshop_digitalization/firebase_consts/firebase_root.dart';

extension ProjectStatuses on FirebaseRoot {
  List<String> get statuses => (this["project-statuses"] ?? []).cast<String>();
  set statuses(List<String> statuses) => this["project-statuses"] = statuses;
}