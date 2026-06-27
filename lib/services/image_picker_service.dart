import 'package:image_picker/image_picker.dart';

/// Serviço responsável por selecionar imagens da galeria do dispositivo.
///
/// Essa separação impede que ViewModels e telas dependam diretamente dos
/// detalhes do pacote usado para acessar imagens do sistema.
class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService({
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  Future<String?> selecionarImagemDaGaleria() async {
    final imagemSelecionada = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    return imagemSelecionada?.path;
  }
}
