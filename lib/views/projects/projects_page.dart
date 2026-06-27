import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/actions/share_image_action.dart';
import '../../common/dialogs/confirmation_dialog.dart';
import '../../common/dialogs/project_name_dialog.dart';
import '../../common/widgets/app_empty_state_widget.dart';
import '../../services/system_message_service.dart';
import '../../viewmodels/editor_view_model.dart';
import '../../viewmodels/project_view_model.dart';
import '../../viewmodels/settings_view_model.dart';
import 'project_card_widget.dart';

class ProjectsPage extends StatelessWidget {
  final VoidCallback onOpenProject;

  const ProjectsPage({super.key, required this.onOpenProject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projetos')),
      body: Consumer<ProjectViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.carregando) {
            return const Center(child: CircularProgressIndicator());
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
            padding: const EdgeInsets.all(2),
            itemCount: projetos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final projeto = projetos[index];

              return ProjectCardWidget(
                project: projeto,
                onOpen: () async {
                  final podeAbrir = await _confirmarAberturaDeProjeto(
                    context: context,
                    projectId: projeto.id,
                    projectName: projeto.name,
                  );

                  if (!context.mounted || !podeAbrir) return;

                  context.read<EditorViewModel>().carregarProjeto(projeto);

                  context.read<SystemMessageService>().mostrarInformacao(
                    context: context,
                    mensagem: 'Projeto "${projeto.name}" aberto no editor.',
                    mensagensAtivas: _mensagensDoSistemaAtivas(context),
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
                onShare: () {
                  ShareImageAction.compartilharImagemSalva(
                    context: context,
                    imagePath: projeto.currentImagePath,
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

    if (criouProjeto) {
      context.read<SystemMessageService>().mostrarInformacao(
        context: context,
        mensagem: 'Projeto criado com imagem selecionada.',
        mensagensAtivas: _mensagensDoSistemaAtivas(context),
      );
    } else {
      context.read<SystemMessageService>().mostrarErro(
        context: context,
        mensagem: viewModel.mensagemErro ?? 'Nenhuma imagem foi selecionada.',
      );
    }
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

    await context.read<ProjectViewModel>().renomearProjeto(projectId, novoNome);
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

    context.read<SystemMessageService>().mostrarInformacao(
      context: context,
      mensagem: 'Projeto "$projectName" excluído.',
      mensagensAtivas: _mensagensDoSistemaAtivas(context),
    );
  }

  Future<bool> _confirmarAberturaDeProjeto({
    required BuildContext context,
    required String projectId,
    required String projectName,
  }) async {
    final editorViewModel = context.read<EditorViewModel>();

    if (!editorViewModel.possuiProjetoAberto) {
      return true;
    }

    if (editorViewModel.projectId == projectId) {
      return true;
    }

    final confirmou = await showConfirmationDialog(
      context: context,
      title: 'Trocar projeto',
      message:
          'Já existe um projeto aberto no editor. Deseja fechar o projeto atual e abrir "$projectName"? Alterações não salvas no editor podem ser perdidas.',
      cancelLabel: 'Cancelar',
      confirmLabel: 'Abrir projeto',
    );

    return confirmou;
  }

  bool _mensagensDoSistemaAtivas(BuildContext context) {
    return context.read<SettingsViewModel>().configuracoes.showSystemMessages;
  }
}
