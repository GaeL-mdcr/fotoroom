import '../models/project_model.dart';
import 'project_repository.dart';

class ProjectLocalRepository implements ProjectRepository {
  final List<ProjectModel> _projetos = [];

  @override
  Future<List<ProjectModel>> listarProjetos() async {
    return List.unmodifiable(_projetos);
  }

  @override
  Future<void> salvarProjeto(ProjectModel projeto) async {
    final index = _projetos.indexWhere(
      (item) => item.id == projeto.id,
    );

    if (index == -1) {
      _projetos.add(projeto);
      return;
    }

    _projetos[index] = projeto;
  }

  @override
  Future<void> excluirProjeto(String id) async {
    _projetos.removeWhere(
      (projeto) => projeto.id == id,
    );
  }
}
