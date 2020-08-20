import '../element_manager.dart';
import 'project.dart';

class ProjectElementManager implements ElementManager<Project> {
  final ProjectManager projectManager;

  ProjectElementManager(this.projectManager);

  Future<Project> createEmpty() => projectManager.createEmpty();

  Future<void> delete(Project elem) => projectManager.delete(elem);
  Future<void> save(Project elem) => projectManager.save(elem);

  Project getById(String id) => projectManager.getProject(id);
}
