import 'package:image_picker/image_picker.dart';

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
