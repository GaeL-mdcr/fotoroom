import 'dart:typed_data';

import 'package:flutter/material.dart';

abstract class ImageEditorAdapter {
  Widget buildEditor({
    required String imagePath,
    required ValueChanged<Uint8List> onImageEditingComplete,
    required VoidCallback onCloseEditor,
  });
}
