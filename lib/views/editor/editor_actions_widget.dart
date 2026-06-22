import 'package:flutter/material.dart';

import '../../common/app_spacing.dart';

class EditorActionsWidget extends StatelessWidget {
  final bool compartilhando;
  final VoidCallback onEdit;
  final VoidCallback? onShare;

  const EditorActionsWidget({
    super.key,
    required this.compartilhando,
    required this.onEdit,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.tune),
          label: const Text('Editar imagem'),
        ),
        const SizedBox(height: AppSpacing.small),
        OutlinedButton.icon(
          onPressed: compartilhando ? null : onShare,
          icon: const Icon(Icons.share),
          label: Text(
            compartilhando ? 'Compartilhando...' : 'Compartilhar imagem',
          ),
        ),
      ],
    );
  }
}
