import 'package:flutter/material.dart';

import '../../models/editor_state_model.dart';

class EditorPreviewWidget extends StatelessWidget {
  final EditorStateModel editorState;

  const EditorPreviewWidget({
    super.key,
    required this.editorState,
  });

  @override
  Widget build(BuildContext context) {
    final previewColor = _obterCorDoFiltro(context);
    final opacity = _calcularOpacidade(editorState.saturation);

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: editorState.rotationTurns,
          child: Transform.scale(
            scaleX: editorState.flipHorizontal ? -1 : 1,
            scaleY: editorState.flipVertical ? -1 : 1,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: previewColor.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: _calcularSombra(editorState.contrast),
                    spreadRadius: 1,
                    color: Colors.black.withValues(alpha: 0.18),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 60,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preview simulado',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _PreviewInfoChip(
                    label: 'Filtro',
                    value: editorState.filterType.label,
                  ),
                  const SizedBox(height: 4),
                  _PreviewInfoChip(
                    label: 'Brilho',
                    value: editorState.brightness.toStringAsFixed(2),
                  ),
                  const SizedBox(height: 4),
                  _PreviewInfoChip(
                    label: 'Contraste',
                    value: editorState.contrast.toStringAsFixed(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _obterCorDoFiltro(BuildContext context) {
    switch (editorState.filterType) {
      case EditorFilterType.grayscale:
        return Colors.grey;
      case EditorFilterType.warm:
        return Colors.orange;
      case EditorFilterType.cool:
        return Colors.blue;
      case EditorFilterType.none:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }

  double _calcularOpacidade(double saturation) {
    final value = 0.55 + saturation;
    return value.clamp(0.2, 1.0);
  }

  double _calcularSombra(double contrast) {
    final value = 12 + (contrast * 8);
    return value.clamp(4, 24);
  }
}

class _PreviewInfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewInfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
