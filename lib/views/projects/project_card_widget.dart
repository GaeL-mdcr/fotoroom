import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/project_model.dart';

class ProjectCardWidget extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const ProjectCardWidget({
    super.key,
    required this.project,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = project.thumbnailPath ?? project.currentImagePath;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProjectImage(imagePath: imagePath),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _ProjectMenuButton(
                      onRename: onRename,
                      onDelete: onDelete,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                project.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectImage extends StatelessWidget {
  final String imagePath;

  const _ProjectImage({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.image_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 36,
          ),
        );
      },
    );
  }
}

class _ProjectMenuButton extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ProjectMenuButton({
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      child: PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Opções do projeto',
        onSelected: (value) {
          if (value == 'rename') {
            onRename();
          }

          if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem(
              value: 'rename',
              child: Text('Renomear'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Excluir'),
            ),
          ];
        },
      ),
    );
  }
}
