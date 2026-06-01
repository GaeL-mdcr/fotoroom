import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class EditorPreviewWidget extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageBytes;

  const EditorPreviewWidget({
    super.key,
    required this.imagePath,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 340,
        width: double.infinity,
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Center(
            child: _buildImage(context),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final bytes = imageBytes;

    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
      );
    }

    final path = imagePath;

    if (path == null || path.trim().isEmpty) {
      return _buildFallback(context);
    }

    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback(context);
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhuma imagem disponível',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
