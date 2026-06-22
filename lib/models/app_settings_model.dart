enum AppThemeMode { system, light, dark }

class AppSettingsModel {
  final AppThemeMode themeMode;
  final bool saveExportHistory;
  final bool showSystemMessages;

  const AppSettingsModel({
    this.themeMode = AppThemeMode.system,
    this.saveExportHistory = true,
    this.showSystemMessages = true,
  });

  AppSettingsModel copyWith({
    AppThemeMode? themeMode,
    bool? saveExportHistory,
    bool? showSystemMessages,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      saveExportHistory: saveExportHistory ?? this.saveExportHistory,
      showSystemMessages: showSystemMessages ?? this.showSystemMessages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'saveExportHistory': saveExportHistory,
      'showSystemMessages': showSystemMessages,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      themeMode: AppThemeMode.values.firstWhere(
        (item) => item.name == map['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      saveExportHistory: map['saveExportHistory'] as bool? ?? true,
      showSystemMessages: map['showSystemMessages'] as bool? ?? true,
    );
  }
}
