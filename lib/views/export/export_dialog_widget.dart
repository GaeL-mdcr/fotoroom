import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/editor_view_model.dart';
import '../../viewmodels/export_view_model.dart';

class ExportDialogWidget extends StatelessWidget {
  const ExportDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExportViewModel, EditorViewModel>(
      builder: (context, exportViewModel, editorViewModel, child) {
        final imagePath = editorViewModel.editedImagePath;
        final possuiImagemFinal =
            imagePath != null && imagePath.trim().isNotEmpty;

        final podeExportar =
            possuiImagemFinal &&
            !exportViewModel.exportando &&
            !exportViewModel.compartilhando;

        return AlertDialog(
          title: const Text('Exportar imagem'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!possuiImagemFinal) ...[
                  const Icon(Icons.info_outline, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Para exportar, primeiro edite a imagem e confirme no editor.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'O FotoRoom exporta a imagem final em JPG.',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (possuiImagemFinal) ...[
                  const Icon(Icons.image_outlined, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'A imagem final será exportada em JPG.',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (exportViewModel.exportando) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('Preparando imagem...'),
                ],
                if (exportViewModel.caminhoArquivoExportado != null) ...[
                  const SizedBox(height: 12),
                  const Icon(Icons.check_circle_outline, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Arquivo pronto:\n${exportViewModel.caminhoArquivoExportado}',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (exportViewModel.mensagemErro != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    exportViewModel.mensagemErro!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                exportViewModel.limparResultado();
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
            if (exportViewModel.possuiArquivoExportado)
              TextButton.icon(
                onPressed: exportViewModel.compartilhando
                    ? null
                    : () async {
                        await exportViewModel.compartilharArquivoExportado();

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Compartilhamento solicitado.'),
                          ),
                        );
                      },
                icon: const Icon(Icons.share),
                label: const Text('Compartilhar'),
              ),
            FilledButton.icon(
              onPressed: podeExportar
                  ? () async {
                      await exportViewModel.exportarImagem(
                        imagePath: imagePath,
                      );
                    }
                  : null,
              icon: const Icon(Icons.ios_share),
              label: const Text('Preparar JPG'),
            ),
          ],
        );
      },
    );
  }
}
