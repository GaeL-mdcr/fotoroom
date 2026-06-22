import 'package:flutter/material.dart';

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
