import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/project_model.dart';

enum ProjectCardMenuAction { rename, share, pin, delete }

/// Widget visual de um projeto na galeria.
///
/// Ele apenas apresenta o projeto e expõe callbacks para ações como abrir,
/// renomear, compartilhar, fixar e excluir.
class ProjectCardWidget extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onShare;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const ProjectCardWidget({
    super.key,
    required this.project,
    required this.onOpen,
    required this.onRename,
    required this.onShare,
    required this.onTogglePin,
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
            if (project.isPinned)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: _ProjectMenuButton(
                isPinned: project.isPinned,
                onRename: onRename,
                onShare: onShare,
                onTogglePin: onTogglePin,
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
  final bool isPinned;
  final VoidCallback onRename;
  final VoidCallback onShare;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const _ProjectMenuButton({
    required this.isPinned,
    required this.onRename,
    required this.onShare,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProjectCardMenuAction>(
      padding: EdgeInsets.zero,
      iconSize: 20,
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
      ),
      tooltip: 'OpÃ§Ãµes do projeto',
      onSelected: (value) {
        switch (value) {
          case ProjectCardMenuAction.rename:
            onRename();
            break;

          case ProjectCardMenuAction.share:
            onShare();
            break;

          case ProjectCardMenuAction.pin:
            onTogglePin();
            break;

          case ProjectCardMenuAction.delete:
            onDelete();
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: ProjectCardMenuAction.rename,
            child: Text('Renomear'),
          ),
          const PopupMenuItem(
            value: ProjectCardMenuAction.share,
            child: Text('Compartilhar'),
          ),
          PopupMenuItem(
            value: ProjectCardMenuAction.pin,
            child: Text(isPinned ? 'Desfixar' : 'Fixar no topo'),
          ),
          const PopupMenuItem(
            value: ProjectCardMenuAction.delete,
            child: Text('Excluir'),
          ),
        ];
      },
    );
  }
}
