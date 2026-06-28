import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../common/app_colors.dart';

/// Facade do subsistema de edição de imagens do FotoRoom.
///
/// Esta classe concentra a integração com o pacote externo `pro_image_editor`.
/// Sem esta Facade, a tela `EditorPage` precisaria conhecer detalhes de
/// construção do editor, callbacks, ferramentas disponíveis, tema visual,
/// estados de carregamento, salvamento e compartilhamento.
///
/// No padrão GoF Facade, o objetivo é oferecer uma interface mais simples para
/// um subsistema complexo. Aqui, o subsistema complexo é o editor externo de
/// imagens, e esta classe oferece uma entrada coesa para o restante do app.
///
/// A classe também favorece High Cohesion, pois mantém em um único componente
/// as responsabilidades relacionadas à integração visual e comportamental do
/// editor externo.
class ProImageEditorFacadeWidget extends StatefulWidget {
  /// Caminho da imagem que será entregue ao editor externo.
  /// A Facade não escolhe qual imagem usar; essa decisão vem da camada de
  /// apresentação por meio do EditorViewModel.
  final String imagePath;

  /// Callback da aplicação para salvar os bytes editados.
  /// A Facade captura a imagem no editor, mas não sabe como o projeto é
  /// persistido. Essa separação mantém o salvamento fora do widget externo.
  final Future<bool> Function(Uint8List bytes) onSaveImage;

  /// Callback da aplicação para compartilhar a imagem já salva.
  /// A Facade apenas dispara a ação; a regra de exportação/compartilhamento
  /// fica fora do editor, preservando a separação de responsabilidades.
  final Future<bool> Function() onShareSavedImage;

  /// Callback usado para fechar o editor e devolver o controle à aplicação.
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

  /// Centraliza a adaptação visual do pacote externo ao tema do FotoRoom.
  ///
  /// Essa configuração ficaria espalhada pela `EditorPage` se a Facade não
  /// existisse. Ao concentrar o tema aqui, a integração visual do editor externo
  /// fica coesa e mais fácil de alterar.
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

  /// Captura a imagem atual do editor e delega o salvamento para a aplicação.
  ///
  /// Este método é parte importante da Facade: ele conhece a API do
  /// `pro_image_editor`, especificamente `captureEditorImage()`, mas não conhece
  /// os detalhes de persistência do FotoRoom. A persistência continua nos
  /// ViewModels e services apropriados.
  ///
  /// Assim, a Facade faz a mediação entre o subsistema externo e a regra da
  /// aplicação, aplicando Indirection do GRASP.
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

  /// Dispara o compartilhamento da imagem salva sem misturar a regra de
  /// compartilhamento com o editor externo.
  ///
  /// A Facade exibe o botão e controla o estado visual de carregamento, mas a
  /// ação real de compartilhar é delegada para a aplicação por callback.
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

  /// Pequeno helper visual para evitar duplicação entre os botões de salvar e
  /// compartilhar. Ele mantém a Facade mais coesa sem espalhar lógica visual
  /// repetida pela AppBar customizada.
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

  I18n _buildEditorI18n() {
    return const I18n(
      cancel: 'Cancelar',
      undo: 'Desfazer',
      redo: 'Refazer',
      done: 'Concluir',
      remove: 'Remover',
      doneLoadingMsg: 'Aplicando alterações...',
      importStateHistoryMsg: 'Carregando editor...',

      various: I18nVarious(
        loadingDialogMsg: 'Aguarde...',
        closeEditorWarningTitle: 'Fechar editor?',
        closeEditorWarningMessage:
            'Deseja fechar o editor? Alterações não salvas podem ser perdidas.',
        closeEditorWarningConfirmBtn: 'Fechar',
        closeEditorWarningCancelBtn: 'Cancelar',
      ),

      layerInteraction: I18nLayerInteraction(
        remove: 'Remover',
        edit: 'Editar',
        rotateScale: 'Girar e redimensionar',
      ),

      paintEditor: I18nPaintEditor(
        bottomNavigationBarText: 'Desenhar',
        moveAndZoom: 'Mover e ampliar',
        freestyle: 'Livre',
        freestyleArrowStart: 'Livre com seta no início',
        freestyleArrowEnd: 'Livre com seta no fim',
        freestyleArrowStartEnd: 'Livre com setas',
        arrow: 'Seta',
        line: 'Linha',
        rectangle: 'Retângulo',
        circle: 'Círculo',
        dashLine: 'Linha tracejada',
        dashDotLine: 'Linha traço-ponto',
        hexagon: 'Hexágono',
        polygon: 'Polígono',
        blur: 'Desfoque',
        pixelate: 'Pixelar',
        custom1: 'Personalizado 1',
        custom2: 'Personalizado 2',
        custom3: 'Personalizado 3',
        lineWidth: 'Espessura da linha',
        eraser: 'Borracha',
        toggleFill: 'Alternar preenchimento',
        changeOpacity: 'Alterar opacidade',
        opacity: 'Opacidade',
        color: 'Cor',
        strokeWidth: 'Espessura',
        fill: 'Preenchimento',
        undo: 'Desfazer',
        redo: 'Refazer',
        done: 'Concluir',
        back: 'Voltar',
        cancel: 'Cancelar',
        smallScreenMoreTooltip: 'Mais',
      ),

      textEditor: I18nTextEditor(
        bottomNavigationBarText: 'Texto',
        inputHintText: 'Digite o texto',
        back: 'Voltar',
        done: 'Concluir',
        textAlign: 'Alinhar texto',
        fontScale: 'Tamanho da fonte',
        backgroundMode: 'Fundo do texto',
        smallScreenMoreTooltip: 'Mais',
      ),

      cropRotateEditor: I18nCropRotateEditor(
        bottomNavigationBarText: 'Recortar',
        rotate: 'Girar',
        flip: 'Espelhar',
        ratio: 'Proporção',
        back: 'Voltar',
        done: 'Concluir',
        cancel: 'Cancelar',
        undo: 'Desfazer',
        redo: 'Refazer',
        reset: 'Redefinir',
        smallScreenMoreTooltip: 'Mais',
      ),

      tuneEditor: I18nTuneEditor(
        bottomNavigationBarText: 'Ajustes',
        back: 'Voltar',
        done: 'Concluir',
        brightness: 'Brilho',
        contrast: 'Contraste',
        saturation: 'Saturação',
        exposure: 'Exposição',
        hue: 'Matiz',
        temperature: 'Temperatura',
        sharpness: 'Nitidez',
        fade: 'Desbotar',
        luminance: 'Luminância',
        undo: 'Desfazer',
        redo: 'Refazer',
      ),

      filterEditor: I18nFilterEditor(
        bottomNavigationBarText: 'Filtros',
        back: 'Voltar',
        done: 'Concluir',
        filters: I18nFilters(
          none: 'Sem filtro',
          addictiveBlue: 'Azul intenso',
          addictiveRed: 'Vermelho intenso',
          aden: 'Aden',
          amaro: 'Amaro',
          ashby: 'Ashby',
          brannan: 'Brannan',
          brooklyn: 'Brooklyn',
          charmes: 'Charmes',
          clarendon: 'Clarendon',
          crema: 'Crema',
          dogpatch: 'Dogpatch',
          earlybird: 'Earlybird',
          f1977: '1977',
          gingham: 'Gingham',
          ginza: 'Ginza',
          hefe: 'Hefe',
          helena: 'Helena',
          hudson: 'Hudson',
          inkwell: 'Preto e branco',
          juno: 'Juno',
          kelvin: 'Kelvin',
          lark: 'Lark',
          loFi: 'Lo-Fi',
          ludwig: 'Ludwig',
          maven: 'Maven',
          mayfair: 'Mayfair',
          moon: 'Moon',
          nashville: 'Nashville',
          perpetua: 'Perpetua',
          reyes: 'Reyes',
          rise: 'Rise',
          sierra: 'Sierra',
          skyline: 'Skyline',
          slumber: 'Slumber',
          stinson: 'Stinson',
          sutro: 'Sutro',
          toaster: 'Toaster',
          valencia: 'Valencia',
          vesper: 'Vesper',
          walden: 'Walden',
          willow: 'Willow',
          xProII: 'X-Pro II',
        ),
      ),

      blurEditor: I18nBlurEditor(
        bottomNavigationBarText: 'Desfoque',
        back: 'Voltar',
        done: 'Concluir',
      ),

      emojiEditor: I18nEmojiEditor(
        bottomNavigationBarText: 'Emoji',
        search: 'Pesquisar',
        categoryRecent: 'Recentes',
        categorySmileys: 'Carinhas e pessoas',
        categoryAnimals: 'Animais e natureza',
        categoryFood: 'Comida e bebida',
        categoryActivities: 'Atividades',
        categoryTravel: 'Viagens e lugares',
        categoryObjects: 'Objetos',
        categorySymbols: 'Símbolos',
        categoryFlags: 'Bandeiras',
        enableSearchAutoI18n: true,
        locale: Locale('pt', 'BR'),
      ),
      stickerEditor: I18nStickerEditor(
        bottomNavigationBarText: 'Figurinhas',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aqui a Facade monta o subsistema externo. A EditorPage não instancia
    // ProImageEditor.file diretamente, nem conhece os objetos de configuração
    // do pacote. Toda essa complexidade fica protegida dentro da Facade.
    return ProImageEditor.file(
      File(widget.imagePath),
      // Callbacks do pacote externo são traduzidos para callbacks da aplicação.
      // Isso evita que o domínio do FotoRoom fique acoplado diretamente ao ciclo
      // interno do pro_image_editor.
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          await widget.onSaveImage(bytes);
        },
        onCloseEditor: (_) {
          widget.onCloseEditor();
        },
      ),
      // A configuração do editor externo fica concentrada aqui: tema, ferramentas,
      // subeditores, AppBar customizada e comportamento visual. Esse é o principal
      // papel da Facade neste projeto.
      configs: ProImageEditorConfigs(
        theme: _buildEditorTheme(context),
        i18n: _buildEditorI18n(),
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
          // A AppBar padrão do editor é substituída por uma AppBar do FotoRoom.
          // Assim, o pacote externo é integrado à experiência visual do app sem
          // expor essa personalização para a tela cliente.
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
                      // O botão Salvar usa a API do editor para capturar a imagem
                      // atual, mas delega a persistência para o callback da aplicação.
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
                      // O botão Compartilhar não salva automaticamente. Ele aciona
                      // o fluxo de compartilhamento da imagem já persistida, mantendo
                      // as ações de salvar e compartilhar separadas.
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
