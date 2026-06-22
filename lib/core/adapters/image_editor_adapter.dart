import 'dart:typed_data';

import 'package:flutter/widgets.dart';

abstract class ImageEditorAdapter {
  Future<Uint8List?> editarImagem({
    required BuildContext context,
    required String imagePath,
  });
}
