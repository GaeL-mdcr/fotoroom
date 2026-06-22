import 'package:flutter/material.dart';

import '../models/app_settings_model.dart';

class SettingsViewModel extends ChangeNotifier {
  AppSettingsModel _configuracoes = const AppSettingsModel();

  AppSettingsModel get configuracoes => _configuracoes;

  void alterarTema(AppThemeMode tema) {
    _configuracoes = _configuracoes.copyWith(themeMode: tema);
    notifyListeners();
  }

  void alterarHistoricoDeExportacao(bool valor) {
    _configuracoes = _configuracoes.copyWith(saveExportHistory: valor);
    notifyListeners();
  }

  void alterarMensagensDoSistema(bool valor) {
    _configuracoes = _configuracoes.copyWith(showSystemMessages: valor);
    notifyListeners();
  }

  void restaurarPadrao() {
    _configuracoes = const AppSettingsModel();
    notifyListeners();
  }
}
