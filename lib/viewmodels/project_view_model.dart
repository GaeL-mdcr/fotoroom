import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../repositories/project_repository.dart';
import '../services/file_storage_service.dart';
import '../services/image_picker_service.dart';
import '../services/project_rules_service.dart';
import 'project_sort_option.dart';

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _repository;
  final ImagePickerService _imagePickerService;
  final ProjectRulesService _projectRulesService;
  final FileStorageService _fileStorageService;

  ProjectViewModel(
    this._repository,
    this._imagePickerService,
    this._projectRulesService,
    this._fileStorageService,
  );

  List<ProjectModel> _projetos = [];
  ProjectSortOption _sortOption = ProjectSortOption.newest;

  bool _carregando = false;
  String? _mensagemErro;

  List<ProjectModel> get projetos => List.unmodifiable(_projetos);
  ProjectSortOption get sortOption => _sortOption;
  bool get carregando => _carregando;
  String? get mensagemErro => _mensagemErro;

  bool get possuiProjetos => _projetos.isNotEmpty;

  String get nomeSugeridoParaNovoProjeto {
    return _projectRulesService.gerarNomeSugerido(_projetos.length);
  }

  List<ProjectModel> get projetosOrdenados {
    final projetosOrdenados = List<ProjectModel>.from(_projetos);

    projetosOrdenados.sort(_compararProjetos);

    return projetosOrdenados;
  }

  void alterarOrdenacao(ProjectSortOption option) {
    if (_sortOption == option) {
      return;
    }

    _sortOption = option;
    notifyListeners();
  }

  Future<void> carregarProjetos() async {
    _carregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      await _recarregarProjetos();
    } catch (_) {
      _mensagemErro = 'Não foi possível carregar os projetos.';
    }

    _carregando = false;
    notifyListeners();
  }

  Future<bool> criarProjeto({
    required String nome,
    required String caminhoImagemOriginal,
  }) async {
    final resultado = _projectRulesService.criarProjeto(
      nome: nome,
      caminhoImagemOriginal: caminhoImagemOriginal,
    );

    if (resultado.isFailure) {
      _mensagemErro = resultado.error;
      notifyListeners();
      return false;
    }

    try {
      final projetoTemporario = resultado.dataOrThrow;

      final caminhoInternoOriginal = await _fileStorageService
          .salvarImagemOriginal(
            projectId: projetoTemporario.id,
            sourceImagePath: caminhoImagemOriginal,
          );

      final projeto = projetoTemporario.copyWith(
        originalImagePath: caminhoInternoOriginal,
        thumbnailPath: caminhoInternoOriginal,
        updatedAt: DateTime.now(),
      );

      await _repository.salvarProjeto(projeto);

      await _recarregarProjetos();
      _mensagemErro = null;

      notifyListeners();

      return true;
    } catch (_) {
      _mensagemErro = 'Não foi possível salvar a imagem do projeto.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> criarProjetoComImagemSelecionada({required String nome}) async {
    _mensagemErro = null;
    notifyListeners();

    try {
      final caminhoImagem = await _imagePickerService
          .selecionarImagemDaGaleria();

      if (caminhoImagem == null) {
        return false;
      }

      _carregando = true;
      notifyListeners();

      final criouProjeto = await criarProjeto(
        nome: nome,
        caminhoImagemOriginal: caminhoImagem,
      );

      return criouProjeto;
    } catch (_) {
      _mensagemErro = 'Não foi possível criar o projeto.';
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> renomearProjeto(String id, String novoNome) async {
    final resultadoNome = _projectRulesService.validarNomeProjeto(novoNome);

    if (resultadoNome.isFailure) {
      _mensagemErro = resultadoNome.error;
      notifyListeners();
      return;
    }

    final projeto = _buscarProjetoPorId(id);

    if (projeto == null) {
      return;
    }

    final projetoAtualizado = projeto.copyWith(
      name: resultadoNome.dataOrThrow,
      updatedAt: DateTime.now(),
    );

    await _salvarProjetoERecarregar(projetoAtualizado);
  }

  Future<void> excluirProjeto(String id) async {
    await _repository.excluirProjeto(id);

    await _recarregarProjetos();

    notifyListeners();
  }

  Future<void> atualizarImagemEditadaDoProjeto({
    required String id,
    required String editedImagePath,
  }) async {
    final projeto = _buscarProjetoPorId(id);

    if (projeto == null) {
      return;
    }

    final projetoAtualizado = projeto.copyWith(
      editedImagePath: editedImagePath,
      thumbnailPath: editedImagePath,
      updatedAt: DateTime.now(),
    );

    await _salvarProjetoERecarregar(projetoAtualizado);
  }

  ProjectModel? _buscarProjetoPorId(String id) {
    for (final projeto in _projetos) {
      if (projeto.id == id) {
        return projeto;
      }
    }

    return null;
  }

  int _compararProjetos(ProjectModel a, ProjectModel b) {
    switch (_sortOption) {
      case ProjectSortOption.newest:
        return b.updatedAt.compareTo(a.updatedAt);

      case ProjectSortOption.oldest:
        return a.updatedAt.compareTo(b.updatedAt);

      case ProjectSortOption.nameAsc:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());

      case ProjectSortOption.nameDesc:
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
    }
  }

  Future<void> _salvarProjetoERecarregar(ProjectModel projeto) async {
    await _repository.salvarProjeto(projeto);

    await _recarregarProjetos();

    notifyListeners();
  }

  Future<void> _recarregarProjetos() async {
    _projetos = await _repository.listarProjetos();
  }
}
