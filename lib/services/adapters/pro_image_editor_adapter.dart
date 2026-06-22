import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/adapters/image_editor_adapter.dart';
import '../facades/pro_image_editor_facade_widget.dart';

class ProImageEditorAdapter implements ImageEditorAdapter {
  @override
  Widget buildEditor({
    required String imagePath,
    required ValueChanged<Uint8List> onImageEditingComplete,
    required VoidCallback onCloseEditor,
  }) {
    return ProImageEditorFacadeWidget(
      imagePath: imagePath,
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
    );
  }
}
