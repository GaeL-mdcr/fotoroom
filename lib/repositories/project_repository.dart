import '../models/project_model.dart';

/// Contrato de persistência dos projetos.
///
/// O ViewModel depende desta abstração, não de uma implementação específica.
/// Isso permite trocar a forma de armazenamento com menor impacto.
abstract class ProjectRepository {
  Future<List<ProjectModel>> listarProjetos();

  Future<void> salvarProjeto(ProjectModel projeto);

  Future<void> excluirProjeto(String id);
}
