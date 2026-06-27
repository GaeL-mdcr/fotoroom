import 'package:flutter/material.dart';

/// Diálogo reutilizável para confirmar ações do usuário.
///
/// Ele centraliza a estrutura visual de confirmações simples, evitando que telas
/// recriem o mesmo padrão de botões e retorno booleano.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelLabel = 'Cancelar',
  String confirmLabel = 'Confirmar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
