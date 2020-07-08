import 'package:mutex/mutex.dart';
import 'package:workshop_digitalization/student_project/project/firebase_project.dart';
import 'package:workshop_digitalization/student_project/student/firebase_student.dart';

class FirebaseManagers {
  static final _instance = FirebaseManagers();
  static FirebaseManagers get instance => _instance;

  final Mutex lock = Mutex();

  Future<void> reset() {
    final tasks = <Future<void>>[
      if (_studentManager != null) _studentManager.dispose(),
      if (_projectManager != null) _projectManager.dispose(),
    ];

    _studentManager = null;
    _projectManager = null;

    return Future.wait(tasks, eagerError: false);
  }

  FirebaseStudentManager _studentManager;
  Future<FirebaseStudentManager> get students async {
    if (_studentManager == null) {
      await lock.acquire();
      if (_studentManager == null) {
        _studentManager = FirebaseStudentManager();
      }
      lock.release();
    }

    return _studentManager;
  }

  FirebaseProjectManager _projectManager;
  Future<FirebaseProjectManager> get projects async {
    if (_projectManager == null) {
      await lock.acquire();
      if (_projectManager == null) {
        _projectManager = FirebaseProjectManager();
      }
      lock.release();
    }

    return _projectManager;
  }
}
