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

/// Tela cliente do padrão Facade aplicado ao editor.
///
/// A tela solicita um editor pela abstração ImageEditorAdapter e fornece
/// callbacks da aplicação, sem conhecer os detalhes do pro_image_editor.
///
/// Isso mantém a tela focada na coordenação do caso de uso e evita que ela fique
/// responsável por detalhes de configuração do editor externo.
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

        // A tela depende da abstração ImageEditorAdapter, não da Facade concreta.
        // Essa decisão reduz acoplamento e permite substituir a implementação do
        // editor com menor impacto.
        final imageEditorAdapter = context.read<ImageEditorAdapter>();

        return Scaffold(
          // A EditorPage atua como cliente do padrão: ela informa a imagem e os
          // callbacks da aplicação, enquanto a Facade cuida da integração com o
          // editor externo.
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

  /// Callback de aplicação chamado pela Facade quando o usuário salva a edição.
  ///
  /// A Facade captura os bytes da imagem, mas este método decide como o FotoRoom
  /// deve persistir essa edição: salva o arquivo, atualiza o projeto e informa o
  /// usuário. Essa separação evita que a Facade conheça regras de persistência
  /// do domínio do aplicativo.
  Future<bool> _salvarImagemEditadaSemFechar(
    BuildContext context,
    EditorViewModel editorViewModel,
    Uint8List bytes,
  ) async {
    if (!context.mounted) return false;

    try {
      // O salvamento da imagem pertence ao EditorViewModel/FileStorageService,
      // não à Facade. Isso preserva SRP: o widget do editor integra a interface,
      // enquanto a persistência fica nas classes responsáveis por dados/arquivos.
      final editedPath = await editorViewModel.salvarImagemEditada(bytes);

      if (!context.mounted || editedPath == null) {
        return false;
      }

      final projectId = editorViewModel.projectId;

      if (projectId == null) {
        return false;
      }

      // Depois que o arquivo editado é salvo, o ProjectViewModel atualiza os dados
      // do projeto para apontar para a nova imagem editada.
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
