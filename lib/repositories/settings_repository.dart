import '../models/app_settings_model.dart';

/// Contrato de persistência das configurações da aplicação.
///
/// O ViewModel depende desta abstração, mantendo a forma de armazenamento das
/// preferências separada da lógica de estado da tela.
abstract class SettingsRepository {
  Future<AppSettingsModel> carregarConfiguracoes();

  Future<void> salvarConfiguracoes(AppSettingsModel configuracoes);
}
