import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

import '../../models/project_model.dart';
import 'project_card_widget.dart';

class ProjectGalleryGridWidget extends StatefulWidget {
  final List<ProjectModel> projects;
  final ValueChanged<List<ProjectModel>> onReorderPinnedProjects;
  final void Function(ProjectModel project) onOpen;
  final void Function(ProjectModel project) onRename;
  final void Function(ProjectModel project) onShare;
  final void Function(ProjectModel project) onTogglePin;
  final void Function(ProjectModel project) onDelete;

  const ProjectGalleryGridWidget({
    super.key,
    required this.projects,
    required this.onReorderPinnedProjects,
    required this.onOpen,
    required this.onRename,
    required this.onShare,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  State<ProjectGalleryGridWidget> createState() =>
      _ProjectGalleryGridWidgetState();
}

class _ProjectGalleryGridWidgetState extends State<ProjectGalleryGridWidget> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gridViewKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.projects.map((project) {
      return ProjectCardWidget(
        key: ValueKey(project.id),
        project: project,
        onOpen: () => widget.onOpen(project),
        onRename: () => widget.onRename(project),
        onShare: () => widget.onShare(project),
        onTogglePin: () => widget.onTogglePin(project),
        onDelete: () => widget.onDelete(project),
      );
    }).toList();

    final nonDraggableIndices = <int>[];

    for (var index = 0; index < widget.projects.length; index++) {
      if (!widget.projects[index].isPinned) {
        nonDraggableIndices.add(index);
      }
    }

    return ReorderableBuilder(
      scrollController: _scrollController,
      nonDraggableIndices: nonDraggableIndices,
      onReorder: (ReorderedListFunction<ProjectModel> reorderedListFunction) {
        final reorderedProjects = reorderedListFunction(widget.projects);

        widget.onReorderPinnedProjects(reorderedProjects);
      },
      builder: (children) {
        return GridView(
          key: _gridViewKey,
          controller: _scrollController,
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          children: children,
        );
      },
      children: children,
    );
  }
}
