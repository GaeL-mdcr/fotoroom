import 'dart:typed_data';

import 'package:flutter/material.dart';

abstract class ImageEditorAdapter {
  Widget buildEditor({
    required String imagePath,
    required Future<bool> Function(Uint8List bytes) onSaveImage,
    required Future<bool> Function() onShareSavedImage,
    required VoidCallback onCloseEditor,
  });
}
