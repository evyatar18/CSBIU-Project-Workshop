import '../element_manager.dart';
import 'student.dart';

class StudentElementManager implements ElementManager<Student> {
  final StudentManager studentManager;

  StudentElementManager(this.studentManager);

  Future<Student> createEmpty() => studentManager.createEmpty();

  Future<void> delete(Student elem) => studentManager.delete(elem);
  Future<void> save(Student elem) => studentManager.save(elem);

  Student getById(String id) => studentManager.getStudent(id);
}
