import 'dart:io';

import 'package:share_plus/share_plus.dart';

/// Serviço responsável por acionar o compartilhamento nativo do sistema.
///
/// Essa separação impede que ViewModels e telas dependam diretamente dos
/// detalhes do pacote de compartilhamento.
class ShareService {
  Future<bool> compartilharArquivo(String filePath) async {
    if (filePath.trim().isEmpty) {
      return false;
    }

    final file = File(filePath);

    if (!await file.exists()) {
      return false;
    }

    final params = ShareParams(files: [XFile(filePath)]);

    final result = await SharePlus.instance.share(params);

    return result.status == ShareResultStatus.success;
  }
}
