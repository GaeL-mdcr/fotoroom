import 'package:flutter/material.dart';

/// Serviço responsável por exibir mensagens simples do sistema.
///
/// Ele centraliza o uso de SnackBars, evitando que regras de fluxo espalhem
/// diretamente detalhes de mensagem visual pela aplicação.
class SystemMessageService {
  void mostrarInformacao({
    required BuildContext context,
    required String mensagem,
    required bool mensagensAtivas,
  }) {
    if (!mensagensAtivas) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void mostrarErro({required BuildContext context, required String mensagem}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
