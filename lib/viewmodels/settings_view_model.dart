import 'package:flutter/material.dart';

import '../models/app_settings_model.dart';
import '../repositories/settings_repository.dart';

/// ViewModel responsável por coordenar as configurações da aplicação.
///
/// Ele mantém o estado das preferências, delega a persistência ao repositório e
/// notifica a interface quando tema ou mensagens do sistema mudam.
class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  AppSettingsModel _configuracoes = const AppSettingsModel();

  SettingsViewModel(this._settingsRepository);

  AppSettingsModel get configuracoes => _configuracoes;

  Future<void> carregarConfiguracoes() async {
    _configuracoes = await _settingsRepository.carregarConfiguracoes();
    notifyListeners();
  }

  Future<void> alterarTema(AppThemeMode tema) async {
    _configuracoes = _configuracoes.copyWith(themeMode: tema);
    notifyListeners();

    await _salvarConfiguracoes();
  }

  Future<void> alterarMensagensDoSistema(bool valor) async {
    _configuracoes = _configuracoes.copyWith(showSystemMessages: valor);
    notifyListeners();

    await _salvarConfiguracoes();
  }

  Future<void> restaurarPadrao() async {
    _configuracoes = const AppSettingsModel();
    notifyListeners();

    await _salvarConfiguracoes();
  }

  Future<void> _salvarConfiguracoes() async {
    await _settingsRepository.salvarConfiguracoes(_configuracoes);
  }
}
