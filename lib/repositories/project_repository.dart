import '../models/project_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectModel>> listarProjetos();

  Future<void> salvarProjeto(ProjectModel projeto);

  Future<void> excluirProjeto(String id);
}
