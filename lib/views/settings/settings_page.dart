import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/app_section_title_widget.dart';
import '../../models/app_settings_model.dart';
import '../../viewmodels/settings_view_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        final configuracoes = viewModel.configuracoes;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações'),
            actions: [
              IconButton(
                tooltip: 'Restaurar padrão',
                onPressed: viewModel.restaurarPadrao,
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          body: ListView(
            children: [
              const AppSectionTitleWidget(title: 'Aparência'),
              RadioGroup<AppThemeMode>(
                groupValue: configuracoes.themeMode,
                onChanged: (value) {
                  if (value == null) return;
                  viewModel.alterarTema(value);
                },
                child: const Column(
                  children: [
                    RadioListTile<AppThemeMode>(
                      title: Text('Tema do sistema'),
                      subtitle: Text('Usa o tema definido no celular'),
                      value: AppThemeMode.system,
                    ),
                    RadioListTile<AppThemeMode>(
                      title: Text('Tema claro'),
                      value: AppThemeMode.light,
                    ),
                    RadioListTile<AppThemeMode>(
                      title: Text('Tema escuro'),
                      value: AppThemeMode.dark,
                    ),
                  ],
                ),
              ),
              const Divider(),
              const AppSectionTitleWidget(title: 'Exportação'),
              SwitchListTile(
                title: const Text('Salvar histórico de exportações'),
                subtitle: const Text(
                  'Registra informações simples das imagens exportadas',
                ),
                value: configuracoes.saveExportHistory,
                onChanged: viewModel.alterarHistoricoDeExportacao,
              ),
              const Divider(),
              const AppSectionTitleWidget(title: 'Sobre o aplicativo'),
              const ListTile(
                leading: Icon(Icons.image_outlined),
                title: Text('FotoRoom'),
                subtitle: Text(
                  'Editor de imagens mobile desenvolvido em Flutter.',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.architecture_outlined),
                title: Text('Arquitetura'),
                subtitle: Text('MVVM com Models, Views, ViewModels e Services.'),
              ),
              const ListTile(
                leading: Icon(Icons.school_outlined),
                title: Text('Projeto acadêmico'),
                subtitle: Text(
                  'Versão simplificada, local e viável para o prazo definido.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
