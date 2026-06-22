import 'package:flutter/material.dart';

import '../services/export_rules_service.dart';
import '../services/image_export_service.dart';
import '../services/share_service.dart';

class ExportViewModel extends ChangeNotifier {
  final ImageExportService _imageExportService;
  final ShareService _shareService;
  final ExportRulesService _exportRulesService;

  bool _compartilhando = false;

  String? _mensagemErro;

  ExportViewModel(
    this._imageExportService,
    this._shareService,
    this._exportRulesService,
  );

  bool get compartilhando => _compartilhando;

  String? get mensagemErro => _mensagemErro;

  Future<bool> compartilharImagem({required String imagePath}) async {
    if (_compartilhando) {
      return false;
    }

    final validacao = _exportRulesService.validarExportacao(
      imagePath: imagePath,
    );

    if (validacao.isFailure) {
      _mensagemErro = validacao.error;
      notifyListeners();
      return false;
    }

    _compartilhando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final caminhoExportado = await _imageExportService.exportarImagemJpg(
        imagePath: imagePath,
      );

      final sucesso = await _shareService.compartilharArquivo(caminhoExportado);

      if (!sucesso) {
        _mensagemErro = 'Não foi possível compartilhar a imagem.';
      }

      return sucesso;
    } catch (_) {
      _mensagemErro = 'Erro ao compartilhar a imagem.';
      return false;
    } finally {
      _compartilhando = false;
      notifyListeners();
    }
  }
}
