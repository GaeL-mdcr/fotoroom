import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/app_colors.dart';
import '../models/app_settings_model.dart';
import '../repositories/project_local_repository.dart';
import '../services/editor_rules_service.dart';
import '../services/export_rules_service.dart';
import '../services/file_storage_service.dart';
import '../services/image_picker_service.dart';
import '../services/image_render_service.dart';
import '../services/project_rules_service.dart';
import '../services/share_service.dart';
import '../viewmodels/editor_view_model.dart';
import '../viewmodels/export_view_model.dart';
import '../viewmodels/project_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../views/home/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final fileStorageService = FileStorageService();

            final viewModel = ProjectViewModel(
              ProjectLocalRepository(fileStorageService),
              ImagePickerService(),
              ProjectRulesService(),
            );

            viewModel.carregarProjetos();

            return viewModel;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => EditorViewModel(
            EditorRulesService(),
            FileStorageService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExportViewModel(
            ImageRenderService(),
            ShareService(),
            ExportRulesService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'FotoRoom',
            debugShowCheckedModeBanner: false,
            themeMode: _converterTema(
              settingsViewModel.configuracoes.themeMode,
            ),
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: AppColors.primary,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.background,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: AppColors.primary,
              brightness: Brightness.dark,
            ),
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
