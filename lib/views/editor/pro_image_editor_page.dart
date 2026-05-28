import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ProImageEditorPage extends StatelessWidget {
  final String imagePath;

  const ProImageEditorPage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(imagePath),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          if (!context.mounted) return;

          Navigator.pop(context, bytes);
        },
        onCloseEditor: (_) {
          if (!context.mounted) return;

          Navigator.pop(context);
        },
      ),
    );
  }
}
