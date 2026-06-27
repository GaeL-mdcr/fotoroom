import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/adapters/image_editor_adapter.dart';
import '../facades/pro_image_editor_facade_widget.dart';

/// Implementação concreta da abstração `ImageEditorAdapter`.
///
/// Esta classe faz a ponte entre o contrato usado pela aplicação e a Facade
/// que encapsula o editor real. Embora seja uma classe pequena, ela tem papel
/// arquitetural importante: impede que a `EditorPage` conheça diretamente a
/// classe `ProImageEditorFacadeWidget` ou o pacote externo `pro_image_editor`.
///
/// Isso reforça baixo acoplamento e Protected Variations do GRASP, pois uma
/// futura troca do editor externo tende a ficar concentrada nesta camada.
class ProImageEditorAdapter implements ImageEditorAdapter {
  @override
  Widget buildEditor({
    required String imagePath,
    required Future<bool> Function(Uint8List bytes) onSaveImage,
    required Future<bool> Function() onShareSavedImage,
    required VoidCallback onCloseEditor,
  }) {
    // A aplicação solicita um editor pela abstração, e o adapter entrega
    // a Facade concreta responsável por montar e configurar o subsistema externo.
    return ProImageEditorFacadeWidget(
      imagePath: imagePath,
      onSaveImage: onSaveImage,
      onShareSavedImage: onShareSavedImage,
      onCloseEditor: onCloseEditor,
    );
  }
}
