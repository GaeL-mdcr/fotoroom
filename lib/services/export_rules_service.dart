import '../common/result.dart';

class ExportRulesService {
  Result<void> validarExportacao({required String? imagePath}) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return const Result.failure(
        'Nenhuma imagem final foi encontrada para exportação.',
      );
    }

    return const Result.success(null);
  }
}
