import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../repositories/project_repository.dart';
import '../services/image_picker_service.dart';
import '../services/project_rules_service.dart';

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _repository;
  final ImagePickerService _imagePickerService;
  final ProjectRulesService _projectRulesService;

  ProjectViewModel(
    this._repository,
    this._imagePickerService,
    this._projectRulesService,
  );

  List<ProjectModel> _projetos = [];

  ProjectModel? _projetoSelecionado;
  bool _carregando = false;
  String? _mensagemErro;

  List<ProjectModel> get projetos => List.unmodifiable(_projetos);
  ProjectModel? get projetoSelecionado => _projetoSelecionado;
  bool get carregando => _carregando;
  String? get mensagemErro => _mensagemErro;

  bool get possuiProjetos => _projetos.isNotEmpty;

  String get nomeSugeridoParaNovoProjeto {
    return _projectRulesService.gerarNomeSugerido(_projetos.length);
  }

  Future<void> carregarProjetos() async {
    _carregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      _projetos = await _repository.listarProjetos();
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

    if (resultado.isFailure || resultado.data == null) {
      _mensagemErro = resultado.error;
      notifyListeners();
      return false;
    }

    try {
      final projeto = resultado.data!;

      await _repository.salvarProjeto(projeto);

      _projetos = await _repository.listarProjetos();
      _projetoSelecionado = projeto;
      _mensagemErro = null;

      notifyListeners();

      return true;
    } catch (_) {
      _mensagemErro = 'Não foi possível salvar o projeto.';
      notifyListeners();

      return false;
    }
  }

  void selecionarProjeto(ProjectModel projeto) {
    _projetoSelecionado = projeto;
    notifyListeners();
  }

  Future<void> renomearProjeto(String id, String novoNome) async {
    final index = _projetos.indexWhere(
      (projeto) => projeto.id == id,
    );

    if (index == -1) return;

    final projetoAtualizado = _projetos[index].copyWith(
      name: novoNome,
      updatedAt: DateTime.now(),
    );

    await _repository.salvarProjeto(projetoAtualizado);

    _projetos = await _repository.listarProjetos();

    if (_projetoSelecionado?.id == id) {
      _projetoSelecionado = projetoAtualizado;
    }

    notifyListeners();
  }

  Future<void> excluirProjeto(String id) async {
    await _repository.excluirProjeto(id);

    _projetos = await _repository.listarProjetos();

    if (_projetoSelecionado?.id == id) {
      _projetoSelecionado = null;
    }

    notifyListeners();
  }

  void definirErro(String? mensagem) {
    _mensagemErro = mensagem;
    notifyListeners();
  }

  Future<void> atualizarImagemEditadaDoProjeto({
    required String id,
    required String editedImagePath,
  }) async {
    final index = _projetos.indexWhere(
      (projeto) => projeto.id == id,
    );

    if (index == -1) return;

    final projetoAtualizado = _projetos[index].copyWith(
      editedImagePath: editedImagePath,
      thumbnailPath: editedImagePath,
      updatedAt: DateTime.now(),
    );

    await _repository.salvarProjeto(projetoAtualizado);

    _projetos = await _repository.listarProjetos();

    if (_projetoSelecionado?.id == id) {
      _projetoSelecionado = projetoAtualizado;
    }

    notifyListeners();
  }

  Future<bool> criarProjetoComImagemSelecionada({
    required String nome,
  }) async {
    _carregando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final caminhoImagem = await _imagePickerService.selecionarImagemDaGaleria();

      if (caminhoImagem == null) {
        _carregando = false;
        notifyListeners();
        return false;
      }

      final criouProjeto = await criarProjeto(
        nome: nome,
        caminhoImagemOriginal: caminhoImagem,
      );

      _carregando = false;
      notifyListeners();

      return criouProjeto;
    } catch (_) {
      _mensagemErro = 'Não foi possível criar o projeto.';
      _carregando = false;
      notifyListeners();

      return false;
    }
  }
}
