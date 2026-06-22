import 'dart:convert';

import '../models/app_settings_model.dart';
import '../services/file_storage_service.dart';
import 'settings_repository.dart';

class SettingsLocalRepository implements SettingsRepository {
  final FileStorageService _storageService;

  static const String _settingsFileName = 'configuracoes.json';

  SettingsLocalRepository(this._storageService);

  @override
  Future<AppSettingsModel> carregarConfiguracoes() async {
    final conteudo = await _storageService.lerArquivoInterno(_settingsFileName);

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
      nomeArquivo: _settingsFileName,
      conteudo: conteudo,
    );
  }
}
