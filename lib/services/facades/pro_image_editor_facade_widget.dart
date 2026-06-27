import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../common/app_colors.dart';

class ProImageEditorFacadeWidget extends StatefulWidget {
  final String imagePath;
  final Future<bool> Function(Uint8List bytes) onSaveImage;
  final Future<bool> Function() onShareSavedImage;
  final VoidCallback onCloseEditor;

  const ProImageEditorFacadeWidget({
    super.key,
    required this.imagePath,
    required this.onSaveImage,
    required this.onShareSavedImage,
    required this.onCloseEditor,
  });

  @override
  State<ProImageEditorFacadeWidget> createState() {
    return _ProImageEditorFacadeWidgetState();
  }
}

class _ProImageEditorFacadeWidgetState
    extends State<ProImageEditorFacadeWidget> {
  bool _salvando = false;
  bool _compartilhando = false;

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

  Future<void> _salvarSemFechar(ProImageEditorState editor) async {
    if (_salvando || _compartilhando) return;

    setState(() {
      _salvando = true;
    });

    try {
      final bytes = await editor.captureEditorImage();

      await widget.onSaveImage(bytes);

      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  Future<void> _compartilharImagemSalva() async {
    if (_salvando || _compartilhando) return;

    setState(() {
      _compartilhando = true;
    });

    try {
      await widget.onShareSavedImage();
    } finally {
      if (mounted) {
        setState(() {
          _compartilhando = false;
        });
      }
    }
  }

  Widget _buildActionIcon({required bool loading, required IconData icon}) {
    if (!loading) {
      return Icon(icon);
    }

    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.file(
      File(widget.imagePath),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          await widget.onSaveImage(bytes);
        },
        onCloseEditor: (_) {
          widget.onCloseEditor();
        },
      ),
      configs: ProImageEditorConfigs(
        theme: _buildEditorTheme(context),
        mainEditor: MainEditorConfigs(
          enableCloseButton: true,
          enableZoom: true,
          enableDoubleTapZoom: true,
          enableSubEditorPage: true,
          tools: const [
            SubEditorMode.paint,
            SubEditorMode.text,
            SubEditorMode.cropRotate,
            SubEditorMode.tune,
            SubEditorMode.filter,
            SubEditorMode.blur,
            SubEditorMode.emoji,
          ],
          widgets: MainEditorWidgets(
            appBar: (editor, rebuildStream) {
              return ReactiveAppbar(
                stream: rebuildStream,
                builder: (context) {
                  return AppBar(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.white,
                    title: const Text('Editar imagem'),
                    leading: IconButton(
                      tooltip: 'Fechar editor',
                      icon: const Icon(Icons.close),
                      onPressed: widget.onCloseEditor,
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'Salvar',
                        onPressed: _salvando || _compartilhando
                            ? null
                            : () {
                                _salvarSemFechar(editor);
                              },
                        icon: _buildActionIcon(
                          loading: _salvando,
                          icon: Icons.save,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Compartilhar imagem salva',
                        onPressed: _salvando || _compartilhando
                            ? null
                            : _compartilharImagemSalva,
                        icon: _buildActionIcon(
                          loading: _compartilhando,
                          icon: Icons.share,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          style: const MainEditorStyle(
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
