import '../models/editor_state_model.dart';
import '../models/export_config_model.dart';

class ImageRenderService {
  Future<String> gerarPreview({
    required String originalImagePath,
    required EditorStateModel editorState,
  }) async {
    return originalImagePath;
  }

  Future<String> exportarImagem({
    required String originalImagePath,
    required EditorStateModel editorState,
    required ExportConfigModel exportConfig,
  }) async {
    // Como o pro_image_editor já gera a imagem final,
    // por enquanto exportar significa usar o arquivo atual do projeto.
    return originalImagePath;
  }
}
