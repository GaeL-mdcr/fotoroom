import 'package:flutter/foundation.dart';

import 'file_storage_service.dart';

class ImageExportService {
  final FileStorageService _fileStorageService;

  ImageExportService(
    this._fileStorageService,
  );

  Future exportarImagemJpg({
    required String imagePath,
  }) async {
    debugPrint('Exportando imagem JPG: $imagePath');

    return _fileStorageService.exportarImagemJpg(
      imagePath: imagePath,
    );
  }
}
