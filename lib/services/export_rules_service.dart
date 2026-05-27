import '../common/result.dart';
import '../models/editor_state_model.dart';
import '../models/export_config_model.dart';

class ExportRulesService {
  Result<void> validarExportacao({
    required String? originalImagePath,
    required EditorStateModel editorState,
    required ExportConfigModel exportConfig,
  }) {
    if (originalImagePath == null || originalImagePath.trim().isEmpty) {
      return const Result.failure('Nenhuma imagem foi carregada para exportação.');
    }

    if (exportConfig.quality < 1 || exportConfig.quality > 100) {
      return const Result.failure('A qualidade da exportação deve estar entre 1 e 100.');
    }

    return const Result.success(null);
  }

  int normalizarQualidade(int qualidade) {
    return qualidade.clamp(1, 100);
  }
}
