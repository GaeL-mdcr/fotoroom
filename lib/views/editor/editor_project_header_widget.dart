import 'package:flutter/material.dart';

class EditorProjectHeaderWidget extends StatelessWidget {
  final String projectName;
  final String imagePath;
  final bool hasUnsavedChanges;
  final VoidCallback onClose;

  const EditorProjectHeaderWidget({
    super.key,
    required this.projectName,
    required this.imagePath,
    required this.hasUnsavedChanges,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: const Icon(Icons.folder_open),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  projectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasUnsavedChanges) ...[
                const SizedBox(width: 8),
                Chip(
                  label: const Text('Não salvo'),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            imagePath,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            tooltip: 'Fechar projeto',
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ),
      ),
    );
  }
}
