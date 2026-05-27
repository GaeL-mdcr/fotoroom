import 'package:flutter/material.dart';

enum UnsavedChangesAction {
  save,
  discard,
  cancel,
}

Future<UnsavedChangesAction> showUnsavedChangesDialog({
  required BuildContext context,
  required String message,
}) async {
  final action = await showDialog<UnsavedChangesAction>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Alterações não salvas'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, UnsavedChangesAction.cancel);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, UnsavedChangesAction.discard);
            },
            child: const Text('Descartar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, UnsavedChangesAction.save);
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );

  return action ?? UnsavedChangesAction.cancel;
}
