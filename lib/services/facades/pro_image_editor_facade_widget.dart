import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../common/app_colors.dart';

class ProImageEditorFacadeWidget extends StatefulWidget {
  final String imagePath;
  final ValueChanged<Uint8List> onImageEditingComplete;
  final VoidCallback onCloseEditor;

  const ProImageEditorFacadeWidget({
    super.key,
    required this.imagePath,
    required this.onImageEditingComplete,
    required this.onCloseEditor,
  });

  @override
  State<ProImageEditorFacadeWidget> createState() {
    return _ProImageEditorFacadeWidgetState();
  }
}

class _ProImageEditorFacadeWidgetState
    extends State<ProImageEditorFacadeWidget> {
  bool _finalizando = false;

  ThemeData _buildEditorTheme(BuildContext context) {
    final baseTheme = Theme.of(context);

    return baseTheme.copyWith(
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ).copyWith(
            primary: AppColors.primary,
            primaryContainer: AppColors.primaryDark,
            onPrimary: AppColors.white,
            surface: AppColors.surfaceDark,
            onSurface: AppColors.white,
          ),
      scaffoldBackgroundColor: AppColors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
      sliderTheme: baseTheme.sliderTheme.copyWith(
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.surfaceDark,
        thumbColor: AppColors.primaryLight,
        overlayColor: AppColors.primaryLight.withValues(alpha: 0.18),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.primaryDark,
        modalBackgroundColor: AppColors.primaryDark,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(widget.imagePath),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          if (_finalizando) {
            return;
          }

          _finalizando = true;

          widget.onImageEditingComplete(bytes);
        },
        onCloseEditor: (_) {
          if (_finalizando) {
            return;
          }

          _finalizando = true;

          widget.onCloseEditor();
        },
      ),
      configs: ProImageEditorConfigs(
        theme: _buildEditorTheme(context),
        mainEditor: const MainEditorConfigs(
          enableCloseButton: true,
          enableZoom: true,
          enableDoubleTapZoom: true,
          enableSubEditorPage: true,
          tools: [
            SubEditorMode.paint,
            SubEditorMode.text,
            SubEditorMode.cropRotate,
            SubEditorMode.tune,
            SubEditorMode.filter,
            SubEditorMode.blur,
            SubEditorMode.emoji,
          ],
          style: MainEditorStyle(
            background: AppColors.black,
            appBarBackground: AppColors.primaryDark,
            appBarColor: AppColors.white,
            bottomBarBackground: AppColors.primaryDark,
            bottomBarColor: AppColors.white,
            uiOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        paintEditor: const PaintEditorConfigs(
          style: PaintEditorStyle(
            background: AppColors.black,
            appBarBackground: AppColors.primaryDark,
            appBarColor: AppColors.white,
            bottomBarBackground: AppColors.primaryDark,
            bottomBarActiveItemColor: AppColors.primaryLight,
            bottomBarInactiveItemColor: AppColors.white,
            initialColor: AppColors.primary,
            editSheetBackgroundColor: AppColors.primaryDark,
            editSheetColor: AppColors.white,
            editSheetPreviewAreaColor: AppColors.black,
            uiOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        textEditor: const TextEditorConfigs(
          style: TextEditorStyle(
            background: Color(0xCC000000),
            appBarBackground: AppColors.primaryDark,
            appBarColor: AppColors.white,
            bottomBarBackground: AppColors.primaryDark,
            inputCursorColor: AppColors.primaryLight,
            inputHintColor: AppColors.primaryLight,
            fontScaleBottomSheetBackground: AppColors.primaryDark,
          ),
        ),
        cropRotateEditor: const CropRotateEditorConfigs(
          style: CropRotateEditorStyle(
            background: AppColors.black,
            appBarBackground: AppColors.primaryDark,
            appBarColor: AppColors.white,
            bottomBarBackground: AppColors.primaryDark,
            bottomBarColor: AppColors.white,
            cropCornerColor: AppColors.primaryLight,
            helperLineColor: AppColors.primaryLight,
            aspectRatioSheetBackgroundColor: AppColors.primaryDark,
            aspectRatioSheetForegroundColor: AppColors.white,
            uiOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        tuneEditor: const TuneEditorConfigs(
          style: TuneEditorStyle(
            background: AppColors.black,
            appBarBackground: AppColors.primaryDark,
            appBarColor: AppColors.white,
            bottomBarBackground: AppColors.primaryDark,
            bottomBarActiveItemColor: AppColors.primaryLight,
            bottomBarInactiveItemColor: AppColors.white,
            uiOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        filterEditor: const FilterEditorConfigs(
          style: FilterEditorStyle(
            background: AppColors.black,
            appBarBackground: AppColors.primaryDark,
            appBarColor: AppColors.white,
            previewTextColor: AppColors.white,
            previewSelectedTextColor: AppColors.primaryLight,
            uiOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        blurEditor: const BlurEditorConfigs(
          style: BlurEditorStyle(
            background: AppColors.black,
            appBarBackgroundColor: AppColors.primaryDark,
            appBarForegroundColor: AppColors.white,
            uiOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        layerInteraction: const LayerInteractionConfigs(
          style: LayerInteractionStyle(
            borderColor: AppColors.primaryLight,
            dragSelectionBackground: Color(0x336D28D9),
            dragSelectionBorderColor: AppColors.primaryLight,
            buttonRemoveBackground: AppColors.primaryDark,
            buttonRemoveColor: AppColors.white,
            buttonEditTextBackground: AppColors.primaryDark,
            buttonEditTextColor: AppColors.white,
            buttonScaleRotateBackground: AppColors.primaryDark,
            buttonScaleRotateColor: AppColors.white,
          ),
        ),
      ),
    );
  }
}
