enum AppThemeMode {
  system,
  light,
  dark,
}

class AppSettingsModel {
  final AppThemeMode themeMode;
  final bool saveExportHistory;

  const AppSettingsModel({
    this.themeMode = AppThemeMode.system,
    this.saveExportHistory = true,
  });

  AppSettingsModel copyWith({
    AppThemeMode? themeMode,
    bool? saveExportHistory,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      saveExportHistory: saveExportHistory ?? this.saveExportHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'saveExportHistory': saveExportHistory,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      themeMode: AppThemeMode.values.firstWhere(
        (item) => item.name == map['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      saveExportHistory: map['saveExportHistory'] as bool? ?? true,
    );
  }
}
