import '../models/export_config_model.dart';

class ImageRenderService {
  Future<String> gerarPreview({required String imagePath}) async {
    return imagePath;
  }

  Future<String> exportarImagem({
    required String imagePath,
    required ExportConfigModel exportConfig,
  }) async {
    // Com o pro_image_editor, a imagem já foi editada e salva.
    // Nesta fase, exportar significa usar o arquivo atual do projeto.
    //
    // Mais tarde, se necessário, este método pode copiar o arquivo
    // para uma pasta de exportações ou converter JPG/PNG.
    return imagePath;
  }
}
