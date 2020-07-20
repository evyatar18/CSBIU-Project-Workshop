import 'package:workshop_digitalization/firebase_consts/dynamic_db/setup.dart';
import 'package:workshop_digitalization/firebase_consts/firebase_root.dart';
import 'package:workshop_digitalization/student_project/project/firebase_project.dart';
import 'package:workshop_digitalization/student_project/student/firebase_student.dart';

class ActiveRoot {
  final FirebaseRoot root;

  FirebaseStudentManager _sm;
  FirebaseProjectManager _pm;

  FirebaseStudentManager get studentManager => _sm;
  FirebaseProjectManager get projectManager => _pm;

  final FirebaseInstance firebase;

  ActiveRoot(this.root, this.firebase) {
    _sm = FirebaseStudentManager(this);
    _pm = FirebaseProjectManager(this);
  }

  Future<void> dispose() {
    return Future.wait([
      _sm.dispose(),
      _pm.dispose(),
      // Future.sync(() => root.dispose()),
    ]);
  }
}
