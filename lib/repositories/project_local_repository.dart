import 'dart:convert';

import '../models/project_model.dart';
import '../services/file_storage_service.dart';
import 'project_repository.dart';

class ProjectLocalRepository implements ProjectRepository {
  final FileStorageService _storageService;

  static const String _projectsFileName = 'projetos.json';

  List<ProjectModel> _projetos = [];
  bool _carregado = false;

  ProjectLocalRepository(this._storageService);

  @override
  Future<List<ProjectModel>> listarProjetos() async {
    await _garantirCarregamento();

    return List.unmodifiable(_projetos);
  }

  @override
  Future<void> salvarProjeto(ProjectModel projeto) async {
    await _garantirCarregamento();

    final index = _projetos.indexWhere(
      (item) => item.id == projeto.id,
    );

    if (index == -1) {
      _projetos.add(projeto);
    } else {
      _projetos[index] = projeto;
    }

    await _salvarProjetosNoArquivo();
  }

  @override
  Future<void> excluirProjeto(String id) async {
    await _garantirCarregamento();

    _projetos.removeWhere(
      (projeto) => projeto.id == id,
    );

    await _storageService.excluirDiretorioDoProjeto(id);
    await _salvarProjetosNoArquivo();
  }

  Future<void> _garantirCarregamento() async {
    if (_carregado) return;

    final conteudo = await _storageService.lerArquivoInterno(
      _projectsFileName,
    );

    if (conteudo == null || conteudo.trim().isEmpty) {
      _projetos = [];
      _carregado = true;
      return;
    }

    try {
      final json = jsonDecode(conteudo) as List<dynamic>;

      _projetos = json
          .map(
            (item) => ProjectModel.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      _projetos = [];
    }

    _carregado = true;
  }

  Future<void> _salvarProjetosNoArquivo() async {
    final json = _projetos.map((projeto) => projeto.toMap()).toList();

    final conteudo = jsonEncode(json);

    await _storageService.salvarArquivoInterno(
      nomeArquivo: _projectsFileName,
      conteudo: conteudo,
    );
  }
}
