import 'file_storage_service.dart';

class ImageExportService {
  final FileStorageService _fileStorageService;

  ImageExportService(this._fileStorageService);

  Future<String> exportarImagemJpg({required String imagePath}) async {
    return _fileStorageService.exportarImagemJpg(imagePath: imagePath);
  }
}
