import 'package:flutter/material.dart';

import '../services/export_rules_service.dart';
import '../services/image_export_service.dart';
import '../services/share_service.dart';

class ExportViewModel extends ChangeNotifier {
  final ImageExportService _imageExportService;
  final ShareService _shareService;
  final ExportRulesService _exportRulesService;

  bool _exportando = false;
  bool _compartilhando = false;

  String? _caminhoArquivoExportado;
  String? _mensagemErro;

  ExportViewModel(
    this._imageExportService,
    this._shareService,
    this._exportRulesService,
  );

  bool get exportando => _exportando;
  bool get compartilhando => _compartilhando;

  String? get caminhoArquivoExportado => _caminhoArquivoExportado;
  String? get mensagemErro => _mensagemErro;

  bool get possuiArquivoExportado => _caminhoArquivoExportado != null;

  Future exportarImagem({
    required String imagePath,
  }) async {
    final validacao = _exportRulesService.validarExportacao(
      imagePath: imagePath,
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
      final caminho = await _imageExportService.exportarImagemJpg(
        imagePath: imagePath,
      );

      _caminhoArquivoExportado = caminho;
    } catch (_) {
      _mensagemErro = 'Não foi possível preparar a imagem para exportação.';
    }

    _exportando = false;
    notifyListeners();
  }

  Future compartilharArquivoExportado() async {
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
