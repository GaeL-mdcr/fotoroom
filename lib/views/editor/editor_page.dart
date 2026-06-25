import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/app_spacing.dart';
import '../../common/dialogs/save_edited_image_dialog.dart';
import '../../common/dialogs/unsaved_changes_dialog.dart';
import '../../common/widgets/app_empty_state_widget.dart';
import '../../core/adapters/image_editor_adapter.dart';
import '../../services/system_message_service.dart';
import '../../viewmodels/editor_view_model.dart';
import '../../viewmodels/export_view_model.dart';
import '../../viewmodels/project_view_model.dart';
import '../../viewmodels/settings_view_model.dart';
import 'editor_actions_widget.dart';
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
            appBar: AppBar(title: const Text('Editor')),
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
                  editorViewModel.iniciarModoEdicao();
                },
                icon: const Icon(Icons.tune),
              ),
              IconButton(
                tooltip: 'Compartilhar imagem',
                onPressed:
                    exportViewModel.compartilhando ||
                        !editorViewModel.podeCompartilharImagem
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
          body: Builder(
            builder: (context) {
              if (editorViewModel.modoEdicaoAtivo) {
                final imagePath = editorViewModel.currentImagePath;

                if (imagePath == null || imagePath.trim().isEmpty) {
                  return const AppEmptyStateWidget(
                    icon: Icons.image_not_supported_outlined,
                    title: 'Imagem indisponível',
                    message: 'Não foi possível carregar a imagem do projeto.',
                  );
                }

                final imageEditorAdapter = context.read<ImageEditorAdapter>();

                return imageEditorAdapter.buildEditor(
                  imagePath: imagePath,
                  onImageEditingComplete: (bytes) {
                    _processarImagemEditada(context, editorViewModel, bytes);
                  },
                  onCloseEditor: () {
                    editorViewModel.fecharModoEdicao();
                  },
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EditorProjectHeaderWidget(
                      projectName:
                          editorViewModel.projectName ?? 'Projeto sem nome',
                      imagePath:
                          editorViewModel.currentImagePath ??
                          'Imagem não informada',
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
                    EditorActionsWidget(
                      compartilhando: exportViewModel.compartilhando,
                      onEdit: editorViewModel.iniciarModoEdicao,
                      onShare: editorViewModel.podeCompartilharImagem
                          ? () {
                              _compartilharImagem(context, editorViewModel);
                            }
                          : null,
                    ),
                  ],
                ),
              );
            },
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

    if (!editorViewModel.possuiImagemAtual || imagePath == null) {
      context.read<SystemMessageService>().mostrarErro(
        context: context,
        mensagem: 'Nenhuma imagem disponível para compartilhar.',
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

    final mensagensAtivas = context
        .read<SettingsViewModel>()
        .configuracoes
        .showSystemMessages;

    if (sucesso) {
      context.read<SystemMessageService>().mostrarInformacao(
        context: context,
        mensagem: mensagem,
        mensagensAtivas: mensagensAtivas,
      );
    } else {
      context.read<SystemMessageService>().mostrarErro(
        context: context,
        mensagem: mensagem,
      );
    }
  }

  Future<void> _processarImagemEditada(
    BuildContext context,
    EditorViewModel editorViewModel,
    Uint8List bytes,
  ) async {
    if (!context.mounted) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (!context.mounted) {
      return;
    }

    final saveMode = await showSaveEditedImageDialog(
      context: context,
      hasEditedImage: editorViewModel.possuiImagemEditadaSalva,
    );

    if (!context.mounted || saveMode == SaveEditedImageMode.cancel) {
      editorViewModel.fecharModoEdicao();
      return;
    }

    try {
      editorViewModel.definirImagemEditada(bytes);

      final editedPath = await editorViewModel.salvarImagemEditadaEmArquivo(
        createNewFile: saveMode == SaveEditedImageMode.createNewFile,
      );

      if (!context.mounted || editedPath == null) {
        editorViewModel.fecharModoEdicao();
        return;
      }

      final projectId = editorViewModel.projectId;

      if (projectId == null) {
        editorViewModel.fecharModoEdicao();
        return;
      }

      await context.read<ProjectViewModel>().atualizarImagemEditadaDoProjeto(
        id: projectId,
        editedImagePath: editedPath,
      );

      editorViewModel.marcarImagemEditadaComoSalva(editedPath);

      if (!context.mounted) {
        return;
      }

      final mensagensAtivas = context
          .read<SettingsViewModel>()
          .configuracoes
          .showSystemMessages;

      context.read<SystemMessageService>().mostrarInformacao(
        context: context,
        mensagem: 'Imagem editada salva no projeto.',
        mensagensAtivas: mensagensAtivas,
      );
    } catch (_) {
      editorViewModel.fecharModoEdicao();

      if (!context.mounted) {
        return;
      }

      context.read<SystemMessageService>().mostrarErro(
        context: context,
        mensagem: 'Não foi possível salvar a imagem editada.',
      );
    }
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
