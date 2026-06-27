import 'dart:convert';

import '../models/app_settings_model.dart';
import '../services/file_storage_service.dart';
import 'settings_repository.dart';

/// Implementação local do repositório de configurações usando arquivo JSON.
///
/// Esta classe concentra os detalhes de leitura e escrita das preferências
/// persistidas do usuário.
class SettingsLocalRepository implements SettingsRepository {
  final FileStorageService _storageService;

  SettingsLocalRepository(this._storageService);

  @override
  Future<AppSettingsModel> carregarConfiguracoes() async {
    final conteudo = await _storageService.lerArquivoInterno(
      _storageService.settingsFileName,
    );

    if (conteudo == null || conteudo.trim().isEmpty) {
      return const AppSettingsModel();
    }

    try {
      final map = jsonDecode(conteudo) as Map<String, dynamic>;

      return AppSettingsModel.fromMap(map);
    } catch (_) {
      return const AppSettingsModel();
    }
  }

  @override
  Future<void> salvarConfiguracoes(AppSettingsModel configuracoes) async {
    final conteudo = jsonEncode(configuracoes.toMap());

    await _storageService.salvarArquivoInterno(
      nomeArquivo: _storageService.settingsFileName,
      conteudo: conteudo,
    );
  }
}
