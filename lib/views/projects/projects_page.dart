import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/app_spacing.dart';
import '../../common/dialogs/confirmation_dialog.dart';
import '../../common/dialogs/project_name_dialog.dart';
import '../../common/dialogs/unsaved_changes_dialog.dart';
import '../../common/widgets/app_empty_state_widget.dart';
import '../../viewmodels/editor_view_model.dart';
import '../../viewmodels/project_view_model.dart';
import 'project_card_widget.dart';

class ProjectsPage extends StatelessWidget {
  final VoidCallback onOpenProject;

  const ProjectsPage({
    super.key,
    required this.onOpenProject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetos'),
      ),
      body: Consumer<ProjectViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.carregando) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!viewModel.possuiProjetos) {
            return const AppEmptyStateWidget(
              icon: Icons.folder_open_outlined,
              title: 'Nenhum projeto salvo',
              message:
                  'Toque em Novo para criar um projeto a partir de uma imagem.',
            );
          }

          final projetos = viewModel.projetos;

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: projetos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final projeto = projetos[index];

              return ProjectCardWidget(
                project: projeto,
                onOpen: () async {
                  final podeAbrir = await _verificarAlteracoesAntesDeAbrir(
                    context: context,
                  );

                  if (!context.mounted || !podeAbrir) return;

                  viewModel.selecionarProjeto(projeto);

                  context.read<EditorViewModel>().carregarProjeto(projeto);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Projeto "${projeto.name}" aberto no editor.',
                      ),
                    ),
                  );

                  onOpenProject();
                },
                onRename: () {
                  _mostrarDialogoRenomear(
                    context: context,
                    projectId: projeto.id,
                    currentName: projeto.name,
                  );
                },
                onDelete: () {
                  _mostrarDialogoExcluir(
                    context: context,
                    projectId: projeto.id,
                    projectName: projeto.name,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _criarProjeto(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }

  Future<void> _criarProjeto(BuildContext context) async {
    final viewModel = context.read<ProjectViewModel>();

    final nomeSugerido = viewModel.nomeSugeridoParaNovoProjeto;

    final nome = await showProjectNameDialog(
      context: context,
      title: 'Novo projeto',
      confirmLabel: 'Criar',
      initialValue: nomeSugerido,
    );

    if (!context.mounted || nome == null) return;

    final criouProjeto = await viewModel.criarProjetoComImagemSelecionada(
      nome: nome,
    );

    if (!context.mounted) return;

    final mensagem = criouProjeto
        ? 'Projeto criado com imagem selecionada.'
        : viewModel.mensagemErro ?? 'Nenhuma imagem foi selecionada.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  Future<void> _mostrarDialogoRenomear({
    required BuildContext context,
    required String projectId,
    required String currentName,
  }) async {
    final novoNome = await showProjectNameDialog(
      context: context,
      title: 'Renomear projeto',
      confirmLabel: 'Salvar',
      initialValue: currentName,
    );

    if (!context.mounted || novoNome == null) return;

    await context.read<ProjectViewModel>().renomearProjeto(
          projectId,
          novoNome,
        );
  }

  Future<void> _mostrarDialogoExcluir({
    required BuildContext context,
    required String projectId,
    required String projectName,
  }) async {
    final confirmou = await showConfirmationDialog(
      context: context,
      title: 'Excluir projeto',
      message:
          'Deseja excluir o projeto "$projectName"? Essa ação não poderá ser desfeita.',
      confirmLabel: 'Excluir',
    );

    if (!context.mounted || !confirmou) return;

    final editorViewModel = context.read<EditorViewModel>();

    await context.read<ProjectViewModel>().excluirProjeto(projectId);

    if (editorViewModel.projectId == projectId) {
      editorViewModel.fecharProjeto();
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Projeto "$projectName" excluído.'),
      ),
    );
  }

  Future<bool> _verificarAlteracoesAntesDeAbrir({
    required BuildContext context,
  }) async {
    final editorViewModel = context.read<EditorViewModel>();

    if (!editorViewModel.possuiAlteracoesNaoSalvas) {
      return true;
    }

    final action = await showUnsavedChangesDialog(
      context: context,
      message:
          'Existe uma edição em andamento. O que deseja fazer antes de abrir outro projeto?',
    );

    if (!context.mounted) return false;

    switch (action) {
      case UnsavedChangesAction.cancel:
        return false;

      case UnsavedChangesAction.discard:
        return true;

      case UnsavedChangesAction.save:
        editorViewModel.marcarComoSalvo();
        return true;
    }
  }
}