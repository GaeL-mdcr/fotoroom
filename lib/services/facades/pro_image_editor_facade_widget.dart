import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ProImageEditorFacadeWidget extends StatefulWidget {
  final String imagePath;
  final ValueChanged<Uint8List> onImageEditingComplete;
  final VoidCallback onCloseEditor;

  const ProImageEditorFacadeWidget({
    super.key,
    required this.imagePath,
    required this.onImageEditingComplete,
    required this.onCloseEditor,
  });

  @override
  State<ProImageEditorFacadeWidget> createState() {
    return _ProImageEditorFacadeWidgetState();
  }
}

class _ProImageEditorFacadeWidgetState
    extends State<ProImageEditorFacadeWidget> {
  bool _finalizando = false;

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(widget.imagePath),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          if (_finalizando) {
            return;
          }

          _finalizando = true;

          widget.onImageEditingComplete(bytes);
        },
        onCloseEditor: (_) {
          if (_finalizando) {
            return;
          }

          _finalizando = true;

          widget.onCloseEditor();
        },
      ),
      configs: ProImageEditorConfigs(
        theme: Theme.of(context),
        mainEditor: const MainEditorConfigs(
          enableCloseButton: false,
          enableZoom: true,
          enableDoubleTapZoom: true,
          enableSubEditorPage: true,
          tools: [
            SubEditorMode.paint,
            SubEditorMode.text,
            SubEditorMode.cropRotate,
            SubEditorMode.tune,
            SubEditorMode.filter,
            SubEditorMode.blur,
            SubEditorMode.emoji,
          ],
        ),
      ),
    );
  }
}
