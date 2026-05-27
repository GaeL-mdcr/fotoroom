import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/app_spacing.dart';
import '../../common/dialogs/unsaved_changes_dialog.dart';
import '../../common/widgets/app_empty_state_widget.dart';
import '../../viewmodels/editor_view_model.dart';
import '../../viewmodels/project_view_model.dart';
import '../export/export_dialog_widget.dart';
import 'adjustment_panel_widget.dart';
import 'editor_preview_widget.dart';
import 'editor_project_header_widget.dart';
import 'editor_toolbar_widget.dart';
import 'filter_panel_widget.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.possuiProjetoAberto) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Editor'),
            ),
            body: const AppEmptyStateWidget(
              icon: Icons.edit_outlined,
              title: 'Nenhum projeto aberto',
              message: 'Crie ou abra um projeto na aba Projetos para começar a editar.',
            ),
          );
        }

        final estado = viewModel.estadoAtual;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Editor'),
            actions: [
              IconButton(
                tooltip: 'Salvar projeto',
                onPressed: viewModel.possuiAlteracoesNaoSalvas
                    ? () async {
                        await _salvarProjetoAberto(context, viewModel);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Projeto salvo.'),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.save_outlined),
              ),
              IconButton(
                tooltip: 'Exportar imagem',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const ExportDialogWidget();
                    },
                  );
                },
                icon: const Icon(Icons.ios_share),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              children: [
                EditorProjectHeaderWidget(
                  projectName: viewModel.projectName ?? 'Projeto sem nome',
                  imagePath: viewModel.originalImagePath ?? 'Imagem não informada',
                  hasUnsavedChanges: viewModel.possuiAlteracoesNaoSalvas,
                  onClose: () {
                    _confirmarFechamentoProjeto(context, viewModel);
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                EditorPreviewWidget(
                  editorState: estado,
                ),
                const SizedBox(height: AppSpacing.medium),
                const EditorToolbarWidget(),
                const SizedBox(height: AppSpacing.medium),
                const AdjustmentPanelWidget(),
                const SizedBox(height: AppSpacing.medium),
                const FilterPanelWidget(),
              ],
            ),
          ),
        );
      },
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
        await _salvarProjetoAberto(context, editorViewModel);

        if (!context.mounted) return;

        editorViewModel.fecharProjeto();
        return;
    }
  }

  Future<void> _salvarProjetoAberto(
    BuildContext context,
    EditorViewModel editorViewModel,
  ) async {
    final projectId = editorViewModel.projectId;

    if (projectId == null) return;

    await context.read<ProjectViewModel>().atualizarEstadoDoProjeto(
          id: projectId,
          editorState: editorViewModel.estadoAtual,
        );

    editorViewModel.marcarComoSalvo();
  }
}
