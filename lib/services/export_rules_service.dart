import '../common/result.dart';
import '../models/export_config_model.dart';

class ExportRulesService {
  Result<void> validarExportacao({
    required String? imagePath,
    required ExportConfigModel exportConfig,
  }) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return const Result.failure(
        'Nenhuma imagem foi carregada para exportação.',
      );
    }

    if (exportConfig.quality < 1 || exportConfig.quality > 100) {
      return const Result.failure(
        'A qualidade da exportação deve estar entre 1 e 100.',
      );
    }

    return const Result.success(null);
  }

  int normalizarQualidade(int qualidade) {
    return qualidade.clamp(1, 100);
  }
}
