import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/editor_state_model.dart';
import '../models/project_model.dart';
import '../services/editor_rules_service.dart';
import '../services/file_storage_service.dart';

class EditorViewModel extends ChangeNotifier {
  final EditorRulesService _editorRulesService;
  final FileStorageService _fileStorageService;

  EditorViewModel(this._editorRulesService, this._fileStorageService);

  String? _projectId;
  String? _projectName;
  String? _originalImagePath;
  String? _editedImagePath;
  Uint8List? _imagemEditadaBytes;

  EditorStateModel _estadoAtual = const EditorStateModel();

  final List<EditorStateModel> _historicoAnterior = [];
  final List<EditorStateModel> _historicoPosterior = [];

  bool _possuiAlteracoesNaoSalvas = false;

  String? get projectId => _projectId;
  String? get projectName => _projectName;
  String? get originalImagePath => _originalImagePath;
  String? get editedImagePath => _editedImagePath;
  Uint8List? get imagemEditadaBytes => _imagemEditadaBytes;

  bool get possuiImagemEditadaEmMemoria => _imagemEditadaBytes != null;

  String? get currentImagePath {
    return _editedImagePath ?? _originalImagePath;
  }

  bool get possuiImagemEditadaSalva {
    return _editedImagePath != null && _editedImagePath!.trim().isNotEmpty;
  }

  EditorStateModel get estadoAtual => _estadoAtual;

  bool get possuiProjetoAberto => _projectId != null;
  bool get possuiAlteracoesNaoSalvas => _possuiAlteracoesNaoSalvas;

  bool get podeDesfazer => _historicoAnterior.isNotEmpty;
  bool get podeRefazer => _historicoPosterior.isNotEmpty;

  void carregarProjeto(ProjectModel projeto) {
    _projectId = projeto.id;
    _projectName = projeto.name;
    _originalImagePath = projeto.originalImagePath;
    _editedImagePath = projeto.editedImagePath;
    _estadoAtual = projeto.editorState;
    _imagemEditadaBytes = null;

    _historicoAnterior.clear();
    _historicoPosterior.clear();

    _possuiAlteracoesNaoSalvas = false;

    notifyListeners();
  }

  void fecharProjeto() {
    _projectId = null;
    _projectName = null;
    _originalImagePath = null;
    _editedImagePath = null;
    _estadoAtual = const EditorStateModel();
    _imagemEditadaBytes = null;

    _historicoAnterior.clear();
    _historicoPosterior.clear();

    _possuiAlteracoesNaoSalvas = false;

    notifyListeners();
  }

  void marcarComoSalvo() {
    _possuiAlteracoesNaoSalvas = false;
    notifyListeners();
  }

  void marcarImagemEditadaComoSalva(String editedImagePath) {
    _editedImagePath = editedImagePath;
    _imagemEditadaBytes = null;
    _possuiAlteracoesNaoSalvas = false;

    notifyListeners();
  }

  void _marcarComoAlterado() {
    _possuiAlteracoesNaoSalvas = true;
  }

  void definirImagemEditada(Uint8List bytes) {
    _imagemEditadaBytes = bytes;
    _possuiAlteracoesNaoSalvas = true;

    notifyListeners();
  }

  void salvarEstadoHistorico() {
    final deveSalvar = _editorRulesService.shouldSaveToHistory(
      currentState: _estadoAtual,
      previousHistory: _historicoAnterior,
    );

    if (!deveSalvar) return;

    _historicoAnterior.add(_estadoAtual);

    final historicoLimitado = _editorRulesService.limitHistory(
      _historicoAnterior,
    );

    _historicoAnterior
      ..clear()
      ..addAll(historicoLimitado);

    _historicoPosterior.clear();
  }

  void alterarBrilho(double valor) {
    final valorNormalizado = _editorRulesService.normalizeAdjustment(valor);

    _estadoAtual = _estadoAtual.copyWith(brightness: valorNormalizado);

    _marcarComoAlterado();
    notifyListeners();
  }

  void alterarContraste(double valor) {
    final valorNormalizado = _editorRulesService.normalizeAdjustment(valor);

    _estadoAtual = _estadoAtual.copyWith(contrast: valorNormalizado);

    _marcarComoAlterado();
    notifyListeners();
  }

  void alterarSaturacao(double valor) {
    final valorNormalizado = _editorRulesService.normalizeAdjustment(valor);

    _estadoAtual = _estadoAtual.copyWith(saturation: valorNormalizado);

    _marcarComoAlterado();
    notifyListeners();
  }

  void aplicarFiltro(EditorFilterType filtro) {
    salvarEstadoHistorico();

    _estadoAtual = _estadoAtual.copyWith(filterType: filtro);
    _marcarComoAlterado();
    notifyListeners();
  }

  void rotacionarDireita() {
    salvarEstadoHistorico();

    final novaRotacao = _editorRulesService.normalizeRotationTurns(
      _estadoAtual.rotationTurns + 1,
    );

    _estadoAtual = _estadoAtual.copyWith(rotationTurns: novaRotacao);

    _marcarComoAlterado();
    notifyListeners();
  }

  void espelharHorizontalmente() {
    salvarEstadoHistorico();

    _estadoAtual = _estadoAtual.copyWith(
      flipHorizontal: !_estadoAtual.flipHorizontal,
    );

    _marcarComoAlterado();
    notifyListeners();
  }

  void espelharVerticalmente() {
    salvarEstadoHistorico();

    _estadoAtual = _estadoAtual.copyWith(
      flipVertical: !_estadoAtual.flipVertical,
    );

    _marcarComoAlterado();
    notifyListeners();
  }

  void desfazerEdicao() {
    if (!podeDesfazer) return;

    _historicoPosterior.add(_estadoAtual);
    _estadoAtual = _historicoAnterior.removeLast();

    _marcarComoAlterado();
    notifyListeners();
  }

  void refazerEdicao() {
    if (!podeRefazer) return;

    _historicoAnterior.add(_estadoAtual);
    _estadoAtual = _historicoPosterior.removeLast();

    _marcarComoAlterado();
    notifyListeners();
  }

  void resetarEdicao() {
    if (_editorRulesService.isDefaultState(_estadoAtual)) {
      return;
    }

    salvarEstadoHistorico();

    _estadoAtual = const EditorStateModel();

    _marcarComoAlterado();
    notifyListeners();
  }

  Future<String?> salvarImagemEditadaEmArquivo({
    required bool createNewFile,
  }) async {
    final projectId = _projectId;
    final bytes = _imagemEditadaBytes;

    if (projectId == null || bytes == null) {
      return null;
    }

    final editedPath = await _fileStorageService.salvarImagemEditada(
      projectId: projectId,
      bytes: bytes,
      createNewFile: createNewFile,
    );

    return editedPath;
  }
}
