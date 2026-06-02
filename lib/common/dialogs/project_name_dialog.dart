import 'package:flutter/material.dart';

Future showProjectNameDialog({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  String? initialValue,
}) {
  String nome = initialValue?.trim() ?? '';

  return showDialog(
    context: context,
    builder: (dialogContext) {
      void confirmar() {
        final nomeValidado = nome.trim();

        if (nomeValidado.isEmpty) {
          return;
        }

        Navigator.pop(dialogContext, nomeValidado);
      }

      return AlertDialog(
        title: Text(title),
        content: TextFormField(
          initialValue: initialValue,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nome do projeto',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            nome = value;
          },
          onFieldSubmitted: (_) {
            confirmar();
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
            onPressed: confirmar,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}
