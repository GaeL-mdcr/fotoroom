import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/actions/share_image_action.dart';
import '../../common/widgets/app_empty_state_widget.dart';
import '../../core/adapters/image_editor_adapter.dart';
import '../../services/system_message_service.dart';
import '../../viewmodels/editor_view_model.dart';
import '../../viewmodels/project_view_model.dart';
import '../../viewmodels/settings_view_model.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorViewModel>(
      builder: (context, editorViewModel, child) {
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

        final imagePath = editorViewModel.currentImagePath;

        if (imagePath == null || imagePath.trim().isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Editor')),
            body: const AppEmptyStateWidget(
              icon: Icons.image_not_supported_outlined,
              title: 'Imagem indisponível',
              message: 'Não foi possível carregar a imagem do projeto.',
            ),
          );
        }

        final imageEditorAdapter = context.read<ImageEditorAdapter>();

        return Scaffold(
          body: imageEditorAdapter.buildEditor(
            imagePath: imagePath,
            onSaveImage: (bytes) {
              return _salvarImagemEditadaSemFechar(
                context,
                editorViewModel,
                bytes,
              );
            },
            onShareSavedImage: () {
              return ShareImageAction.compartilharImagemSalva(
                context: context,
                imagePath: editorViewModel.currentImagePath,
              );
            },
            onCloseEditor: () {
              editorViewModel.fecharProjeto();
            },
          ),
        );
      },
    );
  }

  Future<bool> _salvarImagemEditadaSemFechar(
    BuildContext context,
    EditorViewModel editorViewModel,
    Uint8List bytes,
  ) async {
    if (!context.mounted) return false;

    try {
      final editedPath = await editorViewModel.salvarImagemEditada(bytes);

      if (!context.mounted || editedPath == null) {
        return false;
      }

      final projectId = editorViewModel.projectId;

      if (projectId == null) {
        return false;
      }

      await context.read<ProjectViewModel>().atualizarImagemEditadaDoProjeto(
        id: projectId,
        editedImagePath: editedPath,
      );

      editorViewModel.marcarImagemEditadaComoSalva(editedPath);

      if (!context.mounted) return false;

      final mensagensAtivas = context
          .read<SettingsViewModel>()
          .configuracoes
          .showSystemMessages;

      context.read<SystemMessageService>().mostrarInformacao(
        context: context,
        mensagem: 'Imagem salva.',
        mensagensAtivas: mensagensAtivas,
      );

      return true;
    } catch (_) {
      if (!context.mounted) return false;

      context.read<SystemMessageService>().mostrarErro(
        context: context,
        mensagem: 'Não foi possível salvar a imagem.',
      );

      return false;
    }
  }
}
