import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/editor_state_model.dart';

class EditorPreviewWidget extends StatelessWidget {
  final EditorStateModel editorState;
  final String? imagePath;
  final Uint8List? imageBytes;

  const EditorPreviewWidget({
    super.key,
    required this.editorState,
    required this.imagePath,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImagePreview(context),
                    _buildFilterOverlay(),
                    _buildInfoOverlay(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackPreview(context);
        },
      );
    }

    final path = imagePath;

    if (path == null || path.trim().isEmpty) {
      return _buildFallbackPreview(context);
    }

    final file = File(path);

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackPreview(context);
      },
    );
  }

  Widget _buildFallbackPreview(BuildContext context) {
    return Container(
      color: _obterCorDoFiltro(context).withValues(
        alpha: _calcularOpacidade(editorState.saturation),
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
            'Preview da imagem',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOverlay() {
    switch (editorState.filterType) {
      case EditorFilterType.grayscale:
        return Container(
          color: Colors.grey.withValues(alpha: 0.35),
        );

      case EditorFilterType.warm:
        return Container(
          color: Colors.orange.withValues(alpha: 0.20),
        );

      case EditorFilterType.cool:
        return Container(
          color: Colors.blue.withValues(alpha: 0.20),
        );

      case EditorFilterType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoOverlay(BuildContext context) {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 8,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            _PreviewInfoChip(
              label: 'Filtro',
              value: editorState.filterType.label,
            ),
            _PreviewInfoChip(
              label: 'Brilho',
              value: editorState.brightness.toStringAsFixed(2),
            ),
            _PreviewInfoChip(
              label: 'Contraste',
              value: editorState.contrast.toStringAsFixed(2),
            ),
            _PreviewInfoChip(
              label: 'Saturação',
              value: editorState.saturation.toStringAsFixed(2),
            ),
          ],
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
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      ),
    );
  }
}
