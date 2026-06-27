import 'package:flutter/material.dart';

import '../services/file_storage_service.dart';
import '../services/share_service.dart';

/// ViewModel responsável por coordenar o fluxo de compartilhamento.
///
/// Ele prepara a imagem exportada e delega o envio ao ShareService.
///
/// Assim, a View solicita a ação, mas não conhece os detalhes de exportação nem
/// do pacote de compartilhamento usado pelo serviço.
class ExportViewModel extends ChangeNotifier {
  final FileStorageService _fileStorageService;
  final ShareService _shareService;

  bool _compartilhando = false;
  String? _mensagemErro;

  ExportViewModel(this._fileStorageService, this._shareService);

  bool get compartilhando => _compartilhando;
  String? get mensagemErro => _mensagemErro;

  Future<bool> compartilharImagem({required String imagePath}) async {
    if (_compartilhando) {
      return false;
    }

    if (imagePath.trim().isEmpty) {
      _mensagemErro = 'Nenhuma imagem final foi encontrada para exportaÃ§Ã£o.';
      notifyListeners();
      return false;
    }

    _compartilhando = true;
    _mensagemErro = null;
    notifyListeners();

    try {
      final caminhoExportado = await _fileStorageService.exportarImagemJpg(
        imagePath: imagePath,
      );

      final sucesso = await _shareService.compartilharArquivo(caminhoExportado);

      if (!sucesso) {
        _mensagemErro = 'NÃ£o foi possÃ­vel compartilhar a imagem.';
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
