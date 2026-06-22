import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/app_colors.dart';
import '../core/adapters/image_editor_adapter.dart';
import '../models/app_settings_model.dart';
import '../repositories/project_local_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/settings_local_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/adapters/pro_image_editor_adapter.dart';
import '../services/export_rules_service.dart';
import '../services/file_storage_service.dart';
import '../services/image_export_service.dart';
import '../services/image_picker_service.dart';
import '../services/project_rules_service.dart';
import '../services/share_service.dart';
import '../services/system_message_service.dart';
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
        Provider<FileStorageService>(create: (_) => FileStorageService()),
        Provider<SettingsRepository>(
          create: (context) {
            return SettingsLocalRepository(context.read<FileStorageService>());
          },
        ),
        Provider<ImagePickerService>(create: (_) => ImagePickerService()),
        Provider<ProjectRulesService>(create: (_) => ProjectRulesService()),
        Provider<ExportRulesService>(create: (_) => ExportRulesService()),
        Provider<ShareService>(create: (_) => ShareService()),
        Provider<SystemMessageService>(create: (_) => SystemMessageService()),
        Provider<ImageEditorAdapter>(create: (_) => ProImageEditorAdapter()),
        Provider<ImageExportService>(
          create: (context) {
            return ImageExportService(context.read<FileStorageService>());
          },
        ),
        Provider<ProjectRepository>(
          create: (context) {
            return ProjectLocalRepository(context.read<FileStorageService>());
          },
        ),
        ChangeNotifierProvider<ProjectViewModel>(
          create: (context) {
            final viewModel = ProjectViewModel(
              context.read<ProjectRepository>(),
              context.read<ImagePickerService>(),
              context.read<ProjectRulesService>(),
              context.read<FileStorageService>(),
            );

            viewModel.carregarProjetos();

            return viewModel;
          },
        ),
        ChangeNotifierProvider<EditorViewModel>(
          create: (context) {
            return EditorViewModel(context.read<FileStorageService>());
          },
        ),
        ChangeNotifierProvider<ExportViewModel>(
          create: (context) {
            return ExportViewModel(
              context.read<ImageExportService>(),
              context.read<ShareService>(),
              context.read<ExportRulesService>(),
            );
          },
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) {
            final viewModel = SettingsViewModel(
              context.read<SettingsRepository>(),
            );

            viewModel.carregarConfiguracoes();

            return viewModel;
          },
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
