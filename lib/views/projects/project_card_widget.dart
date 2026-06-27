import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/project_model.dart';

class ProjectCardWidget extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const ProjectCardWidget({
    super.key,
    required this.project,
    required this.onOpen,
    required this.onRename,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = project.thumbnailPath ?? project.currentImagePath;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: InkWell(
        onTap: onOpen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ProjectImage(
              imagePath: imagePath,
              imageVersion: project.updatedAt.microsecondsSinceEpoch,
            ),
            Positioned(
              top: 4,
              right: 4,
              child: _ProjectMenuButton(
                onRename: onRename,
                onShare: onShare,
                onDelete: onDelete,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ProjectNameOverlay(projectName: project.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectImage extends StatelessWidget {
  final String imagePath;
  final int imageVersion;

  const _ProjectImage({required this.imagePath, required this.imageVersion});

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);

    return Image.file(
      file,
      key: ValueKey('$imagePath-$imageVersion'),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.image_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 28,
          ),
        );
      },
    );
  }
}

class _ProjectNameOverlay extends StatelessWidget {
  final String projectName;

  const _ProjectNameOverlay({required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
      child: Text(
        projectName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProjectMenuButton extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _ProjectMenuButton({
    required this.onRename,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 20,
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
      ),
      tooltip: 'Opções do projeto',
      onSelected: (value) {
        if (value == 'rename') {
          onRename();
          return;
        }

        if (value == 'share') {
          onShare();
          return;
        }

        if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'rename', child: Text('Renomear')),
          PopupMenuItem(value: 'share', child: Text('Compartilhar')),
          PopupMenuItem(value: 'delete', child: Text('Excluir')),
        ];
      },
    );
  }
}
