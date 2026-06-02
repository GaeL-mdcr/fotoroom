import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ProImageEditorPage extends StatefulWidget {
  final String imagePath;

  const ProImageEditorPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ProImageEditorPage> createState() => _ProImageEditorPageState();
}

class _ProImageEditorPageState extends State<ProImageEditorPage> {
  bool _fechandoEditor = false;

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(widget.imagePath),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          if (_fechandoEditor) return;

          _fechandoEditor = true;

          debugPrint('ProImageEditor retornou ${bytes.length} bytes');

          if (!mounted) return;

          Navigator.pop(
            context,
            bytes,
          );
        },
        onCloseEditor: (_) {
          if (_fechandoEditor) return;

          _fechandoEditor = true;

          if (!mounted) return;

          Navigator.pop(context);
        },
      ),
    );
  }
}
