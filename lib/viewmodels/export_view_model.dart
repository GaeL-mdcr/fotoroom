import 'package:flutter/material.dart';

import '../models/export_config_model.dart';
import '../services/export_rules_service.dart';
import '../services/image_render_service.dart';
import '../services/share_service.dart';

class ExportViewModel extends ChangeNotifier {
  final ImageRenderService _imageRenderService;
  final ShareService _shareService;
  final ExportRulesService _exportRulesService;

  ExportConfigModel _configuracao = const ExportConfigModel();

  bool _exportando = false;
  bool _compartilhando = false;

  String? _caminhoArquivoExportado;
  String? _mensagemErro;

  ExportViewModel(
    this._imageRenderService,
    this._shareService,
    this._exportRulesService,
  );

  ExportConfigModel get configuracao => _configuracao;

  bool get exportando => _exportando;
  bool get compartilhando => _compartilhando;

  String? get caminhoArquivoExportado => _caminhoArquivoExportado;
  String? get mensagemErro => _mensagemErro;

  bool get possuiArquivoExportado => _caminhoArquivoExportado != null;

  void alterarFormato(ExportImageFormat formato) {
    _configuracao = _configuracao.copyWith(format: formato);
    _caminhoArquivoExportado = null;
    _mensagemErro = null;

    notifyListeners();
  }

  void alterarQualidade(int qualidade) {
    final qualidadeAjustada = _exportRulesService.normalizarQualidade(
      qualidade,
    );

    _configuracao = _configuracao.copyWith(quality: qualidadeAjustada);

    _caminhoArquivoExportado = null;
    _mensagemErro = null;

    notifyListeners();
  }

  Future<void> exportarImagem({required String imagePath}) async {
    final validacao = _exportRulesService.validarExportacao(
      imagePath: imagePath,
      exportConfig: _configuracao,
    );

    if (validacao.isFailure) {
      _mensagemErro = validacao.error;
      notifyListeners();
      return;
    }

    _exportando = true;
    _mensagemErro = null;
    _caminhoArquivoExportado = null;
    notifyListeners();

    try {
      final caminho = await _imageRenderService.exportarImagem(
        imagePath: imagePath,
        exportConfig: _configuracao,
      );

      _caminhoArquivoExportado = caminho;
    } catch (_) {
      _mensagemErro = 'Não foi possível exportar a imagem.';
    }

    _exportando = false;
    notifyListeners();
  }

  Future<void> compartilharArquivoExportado() async {
    final caminho = _caminhoArquivoExportado;

    if (caminho == null) {
      _mensagemErro = 'Nenhum arquivo exportado para compartilhar.';
      notifyListeners();
      return;
    }

    _compartilhando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final sucesso = await _shareService.compartilharArquivo(caminho);

      if (!sucesso) {
        _mensagemErro = 'Não foi possível compartilhar o arquivo.';
      }
    } catch (_) {
      _mensagemErro = 'Erro ao compartilhar o arquivo.';
    }

    _compartilhando = false;
    notifyListeners();
  }

  void limparResultado() {
    _caminhoArquivoExportado = null;
    _mensagemErro = null;
    _exportando = false;
    _compartilhando = false;

    notifyListeners();
  }
}
