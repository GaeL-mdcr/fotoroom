import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/export_config_model.dart';
import '../../viewmodels/editor_view_model.dart';
import '../../viewmodels/export_view_model.dart';

class ExportDialogWidget extends StatelessWidget {
  const ExportDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExportViewModel, EditorViewModel>(
      builder: (context, exportViewModel, editorViewModel, child) {
        final config = exportViewModel.configuracao;
        final isJpg = config.format == ExportImageFormat.jpg;

        final originalImagePath = editorViewModel.originalImagePath;
        final podeExportar = originalImagePath != null &&
            !exportViewModel.exportando &&
            !exportViewModel.compartilhando;

        return AlertDialog(
          title: const Text('Exportar imagem'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioGroup<ExportImageFormat>(
                  groupValue: config.format,
                  onChanged: (value) {
                    if (value == null) return;
                    exportViewModel.alterarFormato(value);
                  },
                  child: const Column(
                    children: [
                      RadioListTile<ExportImageFormat>(
                        title: Text('JPG'),
                        subtitle: Text('Arquivo menor, qualidade ajustável'),
                        value: ExportImageFormat.jpg,
                      ),
                      RadioListTile<ExportImageFormat>(
                        title: Text('PNG'),
                        subtitle: Text('Melhor qualidade, arquivo maior'),
                        value: ExportImageFormat.png,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (isJpg) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Qualidade JPG: ${config.quality}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Slider(
                    value: config.quality.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: '${config.quality}%',
                    onChanged: exportViewModel.exportando
                        ? null
                        : (value) {
                            exportViewModel.alterarQualidade(value.round());
                          },
                  ),
                ],
                if (exportViewModel.exportando) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('Exportando imagem...'),
                ],
                if (exportViewModel.caminhoArquivoExportado != null) ...[
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.check_circle_outline,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arquivo gerado: ${exportViewModel.caminhoArquivoExportado}',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (exportViewModel.mensagemErro != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    exportViewModel.mensagemErro!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
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
                            content: Text('Compartilhamento simulado.'),
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
                        originalImagePath: originalImagePath,
                        editorState: editorViewModel.estadoAtual,
                      );
                    }
                  : null,
              icon: const Icon(Icons.ios_share),
              label: const Text('Exportar'),
            ),
          ],
        );
      },
    );
  }
}
