enum AppThemeMode { system, light, dark }

/// Representa as configurações persistidas da aplicação.
///
/// O model guarda apenas dados escolhidos pelo usuário, como tema e exibição de
/// mensagens. Ele não aplica tema nem manipula interface diretamente.
class AppSettingsModel {
  final AppThemeMode themeMode;
  final bool showSystemMessages;

  const AppSettingsModel({
    this.themeMode = AppThemeMode.system,
    this.showSystemMessages = true,
  });

  AppSettingsModel copyWith({
    AppThemeMode? themeMode,
    bool? showSystemMessages,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      showSystemMessages: showSystemMessages ?? this.showSystemMessages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'showSystemMessages': showSystemMessages,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      themeMode: AppThemeMode.values.firstWhere(
        (item) => item.name == map['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      showSystemMessages: map['showSystemMessages'] as bool? ?? true,
    );
  }
}
