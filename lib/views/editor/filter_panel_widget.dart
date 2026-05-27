import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/editor_state_model.dart';
import '../../viewmodels/editor_view_model.dart';

class FilterPanelWidget extends StatelessWidget {
  const FilterPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: const [
                _FilterButton(filterType: EditorFilterType.none),
                _FilterButton(filterType: EditorFilterType.grayscale),
                _FilterButton(filterType: EditorFilterType.warm),
                _FilterButton(filterType: EditorFilterType.cool),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final EditorFilterType filterType;

  const _FilterButton({
    required this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    final filtroAtual = context.watch<EditorViewModel>().estadoAtual.filterType;
    final isSelected = filterType == filtroAtual;

    return ChoiceChip(
      label: Text(filterType.label),
      selected: isSelected,
      onSelected: (_) {
        context.read<EditorViewModel>().aplicarFiltro(filterType);
      },
    );
  }
}
