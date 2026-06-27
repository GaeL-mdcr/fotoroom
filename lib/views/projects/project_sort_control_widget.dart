import 'package:flutter/material.dart';

import '../../viewmodels/project_sort_option.dart';

/// Widget visual para escolha da ordenação da galeria.
///
/// Ele apenas apresenta as opções disponíveis e informa a seleção escolhida por
/// callback, sem ordenar diretamente os projetos.
class ProjectSortControlWidget extends StatelessWidget {
  final ProjectSortOption selectedOption;
  final ValueChanged<ProjectSortOption> onChanged;

  const ProjectSortControlWidget({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<ProjectSortOption>(
          showSelectedIcon: false,
          selected: {selectedOption},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) {
              return;
            }

            onChanged(selection.first);
          },
          segments: const [
            ButtonSegment(
              value: ProjectSortOption.newest,
              icon: Icon(Icons.update),
              label: Text('Recente'),
            ),
            ButtonSegment(
              value: ProjectSortOption.oldest,
              icon: Icon(Icons.history),
              label: Text('Antigo'),
            ),
            ButtonSegment(
              value: ProjectSortOption.nameAsc,
              icon: Icon(Icons.sort_by_alpha),
              label: Text('A-Z'),
            ),
            ButtonSegment(
              value: ProjectSortOption.nameDesc,
              icon: Icon(Icons.sort_by_alpha),
              label: Text('Z-A'),
            ),
          ],
        ),
      ),
    );
  }
}
