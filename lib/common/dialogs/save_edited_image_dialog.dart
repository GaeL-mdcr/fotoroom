import 'package:flutter/material.dart';

enum SaveEditedImageMode { overwrite, createNewProject, cancel }

Future<SaveEditedImageMode> showSaveEditedImageDialog({
  required BuildContext context,
  required bool hasEditedImage,
}) async {
  final result = await showDialog<SaveEditedImageMode>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Salvar edição'),
        content: Text(
          hasEditedImage
              ? 'Deseja substituir a imagem editada atual ou criar um novo projeto com esta edição?'
              : 'Deseja salvar a imagem editada no projeto?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, SaveEditedImageMode.cancel);
            },
            child: const Text('Cancelar'),
          ),
          if (hasEditedImage)
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  SaveEditedImageMode.createNewProject,
                );
              },
              child: const Text('Criar novo projeto'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, SaveEditedImageMode.overwrite);
            },
            child: Text(hasEditedImage ? 'Sobrescrever' : 'Salvar'),
          ),
        ],
      );
    },
  );

  return result ?? SaveEditedImageMode.cancel;
}
