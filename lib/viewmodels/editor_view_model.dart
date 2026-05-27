import 'package:flutter/material.dart';

import '../models/editor_state_model.dart';
import '../models/project_model.dart';
import '../services/editor_rules_service.dart';

class EditorViewModel extends ChangeNotifier {
  final EditorRulesService _editorRulesService;

  EditorViewModel(
    this._editorRulesService,
  );

  String? _projectId;
  String? _projectName;
  String? _originalImagePath;

  EditorStateModel _estadoAtual = const EditorStateModel();

  final List<EditorStateModel> _historicoAnterior = [];
  final List<EditorStateModel> _historicoPosterior = [];

  bool _possuiAlteracoesNaoSalvas = false;

  String? get projectId => _projectId;
  String? get projectName => _projectName;
  String? get originalImagePath => _originalImagePath;

  EditorStateModel get estadoAtual => _estadoAtual;

  bool get possuiProjetoAberto => _projectId != null;
  bool get possuiAlteracoesNaoSalvas => _possuiAlteracoesNaoSalvas;

  bool get podeDesfazer => _historicoAnterior.isNotEmpty;
  bool get podeRefazer => _historicoPosterior.isNotEmpty;

  void carregarProjeto(ProjectModel projeto) {
    _projectId = projeto.id;
    _projectName = projeto.name;
    _originalImagePath = projeto.originalImagePath;
    _estadoAtual = projeto.editorState;

    _historicoAnterior.clear();
    _historicoPosterior.clear();

    _possuiAlteracoesNaoSalvas = false;

    notifyListeners();
  }

  void fecharProjeto() {
    _projectId = null;
    _projectName = null;
    _originalImagePath = null;
    _estadoAtual = const EditorStateModel();

    _historicoAnterior.clear();
    _historicoPosterior.clear();

    _possuiAlteracoesNaoSalvas = false;

    notifyListeners();
  }

  void marcarComoSalvo() {
    _possuiAlteracoesNaoSalvas = false;
    notifyListeners();
  }

  void _marcarComoAlterado() {
    _possuiAlteracoesNaoSalvas = true;
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

    _estadoAtual = _estadoAtual.copyWith(
      brightness: valorNormalizado,
    );

    _marcarComoAlterado();
    notifyListeners();
  }

  void alterarContraste(double valor) {
    final valorNormalizado = _editorRulesService.normalizeAdjustment(valor);

    _estadoAtual = _estadoAtual.copyWith(
      contrast: valorNormalizado,
    );

    _marcarComoAlterado();
    notifyListeners();
  }

  void alterarSaturacao(double valor) {
    final valorNormalizado = _editorRulesService.normalizeAdjustment(valor);

    _estadoAtual = _estadoAtual.copyWith(
      saturation: valorNormalizado,
    );

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

    _estadoAtual = _estadoAtual.copyWith(
      rotationTurns: novaRotacao,
    );

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
}
