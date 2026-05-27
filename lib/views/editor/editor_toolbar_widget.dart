import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/dialogs/confirmation_dialog.dart';
import '../../viewmodels/editor_view_model.dart';

class EditorToolbarWidget extends StatelessWidget {
  const EditorToolbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditorViewModel>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            IconButton(
              tooltip: 'Desfazer',
              onPressed: viewModel.podeDesfazer
                  ? viewModel.desfazerEdicao
                  : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: 'Refazer',
              onPressed: viewModel.podeRefazer
                  ? viewModel.refazerEdicao
                  : null,
              icon: const Icon(Icons.redo),
            ),
            IconButton(
              tooltip: 'Resetar edição',
              onPressed: () {
                _confirmarReset(context, viewModel);
              },
              icon: const Icon(Icons.restart_alt),
            ),
            IconButton(
              tooltip: 'Rotacionar',
              onPressed: viewModel.rotacionarDireita,
              icon: const Icon(Icons.rotate_right),
            ),
            IconButton(
              tooltip: 'Espelhar horizontal',
              onPressed: viewModel.espelharHorizontalmente,
              icon: const Icon(Icons.flip),
            ),
            IconButton(
              tooltip: 'Espelhar vertical',
              onPressed: viewModel.espelharVerticalmente,
              icon: const Icon(Icons.flip_camera_android),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarReset(
    BuildContext context,
    EditorViewModel viewModel,
  ) async {
    final confirmou = await showConfirmationDialog(
      context: context,
      title: 'Resetar edição',
      message: 'Deseja remover todos os ajustes aplicados nesta edição?',
      confirmLabel: 'Resetar',
    );

    if (!confirmou) return;

    viewModel.resetarEdicao();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição resetada.'),
      ),
    );
  }
}
