import 'package:flutter/material.dart';

Future<String?> showProjectNameDialog({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  String initialValue = '',
}) async {
  final controller = TextEditingController(text: initialValue);

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nome do projeto',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            final nome = controller.text.trim();

            if (nome.isEmpty) {
              return;
            }

            Navigator.pop(dialogContext, nome);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final nome = controller.text.trim();

              if (nome.isEmpty) {
                return;
              }

              Navigator.pop(dialogContext, nome);
            },
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );

  controller.dispose();

  return result;
}
