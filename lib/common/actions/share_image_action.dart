import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/system_message_service.dart';
import '../../viewmodels/export_view_model.dart';
import '../../viewmodels/settings_view_model.dart';

/// Ação reutilizável para compartilhar imagens salvas.
///
/// Essa classe evita duplicação entre a galeria e o editor, mantendo o fluxo
/// de compartilhamento em um único ponto da aplicação.
class ShareImageAction {
  const ShareImageAction._();

  static Future<bool> compartilharImagemSalva({
    required BuildContext context,
    required String? imagePath,
  }) async {
    if (imagePath == null || imagePath.trim().isEmpty) {
      context.read<SystemMessageService>().mostrarErro(
        context: context,
        mensagem: 'Nenhuma imagem salva disponível para compartilhar.',
      );

      return false;
    }

    final exportViewModel = context.read<ExportViewModel>();

    final sucesso = await exportViewModel.compartilharImagem(
      imagePath: imagePath,
    );

    if (!context.mounted) return false;

    final mensagem = sucesso
        ? 'Compartilhamento solicitado.'
        : exportViewModel.mensagemErro ??
              'Não foi possível compartilhar a imagem.';

    final mensagensAtivas = context
        .read<SettingsViewModel>()
        .configuracoes
        .showSystemMessages;

    final systemMessageService = context.read<SystemMessageService>();

    if (sucesso) {
      systemMessageService.mostrarInformacao(
        context: context,
        mensagem: mensagem,
        mensagensAtivas: mensagensAtivas,
      );
    } else {
      systemMessageService.mostrarErro(context: context, mensagem: mensagem);
    }

    return sucesso;
  }
}
