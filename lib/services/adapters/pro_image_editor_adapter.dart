import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/adapters/image_editor_adapter.dart';
import '../../views/editor/pro_image_editor_page.dart';

class ProImageEditorAdapter implements ImageEditorAdapter {
  @override
  Future<Uint8List?> editarImagem({
    required BuildContext context,
    required String imagePath,
  }) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (context) {
          return ProImageEditorPage(
            imagePath: imagePath,
          );
        },
      ),
    );
  }
}
