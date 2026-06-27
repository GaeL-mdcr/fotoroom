import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Contrato usado pela aplicação para solicitar um editor de imagem.
///
/// A tela depende desta abstração, e não diretamente do pacote externo.
/// Isso reduz acoplamento e protege a aplicação contra mudanças no editor real.
///
/// No padrão GoF Facade aplicado no FotoRoom, esta interface define o ponto
/// de entrada que a aplicação conhece. A `EditorPage` depende deste contrato,
/// e não da implementação concreta baseada no `pro_image_editor`.
///
/// Essa decisão também favorece o princípio DIP do SOLID: a tela depende de uma
/// abstração, enquanto a implementação concreta pode ser substituída com menor
/// impacto no restante do sistema.
abstract class ImageEditorAdapter {
  /// Cria o editor configurado para a aplicação.
  ///
  /// Os callbacks representam ações do domínio do FotoRoom, como salvar,
  /// compartilhar e fechar o editor. Assim, o editor externo não decide
  /// diretamente como o projeto será salvo ou compartilhado; ele apenas
  /// comunica eventos para a aplicação.
  Widget buildEditor({
    required String imagePath,
    required Future<bool> Function(Uint8List bytes) onSaveImage,
    required Future<bool> Function() onShareSavedImage,
    required VoidCallback onCloseEditor,
  });
}
