import '../models/app_settings_model.dart';

abstract class SettingsRepository {
  Future<AppSettingsModel> carregarConfiguracoes();

  Future<void> salvarConfiguracoes(AppSettingsModel configuracoes);
}
