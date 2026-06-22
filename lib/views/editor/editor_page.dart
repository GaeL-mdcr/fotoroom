import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/app_spacing.dart';
import '../../common/dialogs/save_edited_image_dialog.dart';
import '../../common/dialogs/unsaved_changes_dialog.dart';
import '../../common/widgets/app_empty_state_widget.dart';
import '../../core/adapters/image_editor_adapter.dart';
import '../../viewmodels/editor_view_model.dart';
import '../../viewmodels/export_view_model.dart';
import '../../viewmodels/project_view_model.dart';
import 'editor_preview_widget.dart';
import 'editor_project_header_widget.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EditorViewModel, ExportViewModel>(
      builder: (context, editorViewModel, exportViewModel, child) {
        if (!editorViewModel.possuiProjetoAberto) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Editor'),
            ),
            body: const AppEmptyStateWidget(
              icon: Icons.edit_outlined,
              title: 'Nenhum projeto aberto',
              message:
                  'Crie ou abra um projeto na aba Projetos para começar a editar.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Editor'),
            actions: [
              IconButton(
                tooltip: 'Editar imagem',
                onPressed: () {
                  _abrirEditorDeImagem(context, editorViewModel);
                },
                icon: const Icon(Icons.tune),
              ),
              IconButton(
                tooltip: 'Compartilhar imagem',
                onPressed: exportViewModel.compartilhando
                    ? null
                    : () {
                        _compartilharImagem(context, editorViewModel);
                      },
                icon: exportViewModel.compartilhando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EditorProjectHeaderWidget(
                  projectName: editorViewModel.projectName ?? 'Projeto sem nome',
                  imagePath:
                      editorViewModel.currentImagePath ?? 'Imagem não informada',
                  hasUnsavedChanges:
                      editorViewModel.possuiAlteracoesNaoSalvas,
                  onClose: () {
                    _confirmarFechamentoProjeto(context, editorViewModel);
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                EditorPreviewWidget(
                  key: ValueKey(
                    'preview_${editorViewModel.currentImagePath}_${editorViewModel.previewVersion}',
                  ),
                  imagePath: editorViewModel.currentImagePath,
                  imageBytes: editorViewModel.imagemEditadaBytes,
                ),
                const SizedBox(height: AppSpacing.medium),
                FilledButton.icon(
                  onPressed: () {
                    _abrirEditorDeImagem(context, editorViewModel);
                  },
                  icon: const Icon(Icons.tune),
                  label: const Text('Editar imagem'),
                ),
                const SizedBox(height: AppSpacing.small),
                OutlinedButton.icon(
                  onPressed: exportViewModel.compartilhando
                      ? null
                      : () {
                          _compartilharImagem(context, editorViewModel);
                        },
                  icon: const Icon(Icons.share),
                  label: Text(
                    exportViewModel.compartilhando
                        ? 'Compartilhando...'
                        : 'Compartilhar imagem',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _compartilharImagem(
    BuildContext context,
    EditorViewModel editorViewModel,
  ) async {
    final imagePath = editorViewModel.currentImagePath;

    if (imagePath == null || imagePath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma imagem disponível para compartilhar.'),
        ),
      );

      return;
    }

    final exportViewModel = context.read<ExportViewModel>();

    final sucesso = await exportViewModel.compartilharImagem(
      imagePath: imagePath,
    );

    if (!context.mounted) return;

    final mensagem = sucesso
        ? 'Compartilhamento solicitado.'
        : exportViewModel.mensagemErro ??
            'Não foi possível compartilhar a imagem.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  Future<void> _abrirEditorDeImagem(
    BuildContext context,
    EditorViewModel editorViewModel,
  ) async {
    final imagePath = editorViewModel.currentImagePath;

    if (imagePath == null || imagePath.trim().isEmpty) {
      return;
    }

    final imageEditorAdapter = context.read<ImageEditorAdapter>();

    final bytes = await imageEditorAdapter.editarImagem(
      context: context,
      imagePath: imagePath,
    );

    if (!context.mounted || bytes == null) return;

    debugPrint('EditorPage recebeu imagem editada: ${bytes.length} bytes');

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    if (!context.mounted) return;

    final saveMode = await showSaveEditedImageDialog(
      context: context,
      hasEditedImage: editorViewModel.possuiImagemEditadaSalva,
    );

    if (!context.mounted || saveMode == SaveEditedImageMode.cancel) {
      return;
    }

    editorViewModel.definirImagemEditada(bytes);

    final editedPath = await editorViewModel.salvarImagemEditadaEmArquivo(
      createNewFile: saveMode == SaveEditedImageMode.createNewFile,
    );

    if (!context.mounted || editedPath == null) return;

    debugPrint('Imagem editada salva em: $editedPath');

    final projectId = editorViewModel.projectId;

    if (projectId == null) return;

    await context.read<ProjectViewModel>().atualizarImagemEditadaDoProjeto(
          id: projectId,
          editedImagePath: editedPath,
        );

    editorViewModel.marcarImagemEditadaComoSalva(editedPath);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagem editada salva no projeto.'),
      ),
    );
  }

  Future<void> _confirmarFechamentoProjeto(
    BuildContext context,
    EditorViewModel editorViewModel,
  ) async {
    if (!editorViewModel.possuiAlteracoesNaoSalvas) {
      editorViewModel.fecharProjeto();
      return;
    }

    final action = await showUnsavedChangesDialog(
      context: context,
      message: 'Você deseja salvar o projeto antes de fechar?',
    );

    if (!context.mounted) return;

    switch (action) {
      case UnsavedChangesAction.cancel:
        return;

      case UnsavedChangesAction.discard:
        editorViewModel.fecharProjeto();
        return;

      case UnsavedChangesAction.save:
        editorViewModel.marcarComoSalvo();
        editorViewModel.fecharProjeto();
        return;
    }
  }
}
