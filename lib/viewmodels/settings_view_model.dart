import 'package:flutter/material.dart';

import '../models/app_settings_model.dart';
import '../repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  AppSettingsModel _configuracoes = const AppSettingsModel();
  bool _carregando = false;

  SettingsViewModel(this._settingsRepository);

  AppSettingsModel get configuracoes => _configuracoes;
  bool get carregando => _carregando;

  Future<void> carregarConfiguracoes() async {
    _carregando = true;
    notifyListeners();

    _configuracoes = await _settingsRepository.carregarConfiguracoes();

    _carregando = false;
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
