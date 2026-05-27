import '../models/editor_state_model.dart';
import '../models/export_config_model.dart';

class ImageRenderService {
  Future<String> gerarPreview({
    required String originalImagePath,
    required EditorStateModel editorState,
  }) async {
    // Implementação real será feita depois com o pacote image.
    return originalImagePath;
  }

  Future<String> exportarImagem({
    required String originalImagePath,
    required EditorStateModel editorState,
    required ExportConfigModel exportConfig,
  }) async {
    final extensao = exportConfig.format == ExportImageFormat.png
        ? 'png'
        : 'jpg';

    final nomeFiltro = editorState.filterType.name;
    final baseName = originalImagePath.split('/').last.split('\\').last;

    return 'fotoroom_${nomeFiltro}_$baseName.$extensao';
  }
}
