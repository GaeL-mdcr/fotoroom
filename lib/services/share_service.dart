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

    final params = ShareParams(files: [XFile(filePath)]);

    final result = await SharePlus.instance.share(params);

    return result.status == ShareResultStatus.success;
  }
}
