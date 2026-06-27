import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../repositories/project_repository.dart';
import '../services/file_storage_service.dart';
import '../services/image_picker_service.dart';
import '../services/project_rules_service.dart';
import 'project_sort_option.dart';

/// ViewModel responsável por coordenar os casos de uso da galeria de projetos.
///
/// Ele não desenha interface nem manipula widgets. Sua função é organizar o
/// estado da tela, chamar services/repositories e notificar mudanças.
///
/// No MVVM, ele atua como intermediário entre a View e as regras da aplicação;
/// no GRASP, cumpre papel de Controller para as ações da galeria.
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
    final fixados = _projetos.where((projeto) => projeto.isPinned).toList()
      ..sort((a, b) => a.pinnedIndex.compareTo(b.pinnedIndex));

    final naoFixados = _projetos.where((projeto) => !projeto.isPinned).toList()
      ..sort(_compararProjetosNaoFixados);

    return [...fixados, ...naoFixados];
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
      _mensagemErro = 'NÃ£o foi possÃ­vel carregar os projetos.';
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
      _mensagemErro = 'NÃ£o foi possÃ­vel salvar a imagem do projeto.';
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
      _mensagemErro = 'NÃ£o foi possÃ­vel criar o projeto.';
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

  Future<void> alternarFixado(String id) async {
    final projeto = _buscarProjetoPorId(id);

    if (projeto == null) {
      return;
    }

    final vaiFixar = !projeto.isPinned;

    final novoPinnedIndex = vaiFixar ? _proximoPinnedIndex() : 0;

    final projetoAtualizado = projeto.copyWith(
      isPinned: vaiFixar,
      pinnedIndex: novoPinnedIndex,
      updatedAt: DateTime.now(),
    );

    await _salvarProjetoERecarregar(projetoAtualizado);
  }

  Future<void> reordenarProjetosFixados(
    List<ProjectModel> projetosReordenados,
  ) async {
    final fixadosReordenados = projetosReordenados
        .where((projeto) => projeto.isPinned)
        .toList();

    for (var index = 0; index < fixadosReordenados.length; index++) {
      final projeto = fixadosReordenados[index];

      await _repository.salvarProjeto(
        projeto.copyWith(pinnedIndex: index, updatedAt: DateTime.now()),
      );
    }

    await _recarregarProjetos();
    notifyListeners();
  }

  ProjectModel? _buscarProjetoPorId(String id) {
    for (final projeto in _projetos) {
      if (projeto.id == id) {
        return projeto;
      }
    }

    return null;
  }

  int _proximoPinnedIndex() {
    final fixados = _projetos.where((projeto) => projeto.isPinned);

    if (fixados.isEmpty) {
      return 0;
    }

    final maiorIndex = fixados
        .map((projeto) => projeto.pinnedIndex)
        .reduce((a, b) => a > b ? a : b);

    return maiorIndex + 1;
  }

  int _compararProjetosNaoFixados(ProjectModel a, ProjectModel b) {
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
