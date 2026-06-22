import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../views/home/home_page.dart';
import 'app_providers.dart';
import 'app_theme.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.build(),
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'FotoRoom',
            debugShowCheckedModeBanner: false,
            themeMode: _converterTema(
              settingsViewModel.configuracoes.themeMode,
            ),
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const HomePage(),
          );
        },
      ),
    );
  }

  ThemeMode _converterTema(AppThemeMode tema) {
    switch (tema) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
