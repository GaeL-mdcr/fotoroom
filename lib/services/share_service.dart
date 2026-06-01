import 'dart:io';

import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<bool> compartilharArquivo(String filePath) async {
    if (filePath.trim().isEmpty) {
      return false;
    }

    final file = File(filePath);

    if (!await file.exists()) {
      return false;
    }

    final result = await Share.shareXFiles(
      [
        XFile(filePath),
      ],
      text: 'Imagem editada no FotoRoom',
    );

    return result.status == ShareResultStatus.success;
  }
}
