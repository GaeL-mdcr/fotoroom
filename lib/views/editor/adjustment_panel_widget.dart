import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/editor_view_model.dart';

class AdjustmentPanelWidget extends StatelessWidget {
  const AdjustmentPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditorViewModel>();
    final estado = viewModel.estadoAtual;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _AdjustmentSlider(
              label: 'Brilho',
              value: estado.brightness,
              onChangeStart: (_) {
                viewModel.salvarEstadoHistorico();
              },
              onChanged: viewModel.alterarBrilho,
            ),
            _AdjustmentSlider(
              label: 'Contraste',
              value: estado.contrast,
              onChangeStart: (_) {
                viewModel.salvarEstadoHistorico();
              },
              onChanged: viewModel.alterarContraste,
            ),
            _AdjustmentSlider(
              label: 'Saturação',
              value: estado.saturation,
              onChangeStart: (_) {
                viewModel.salvarEstadoHistorico();
              },
              onChanged: viewModel.alterarSaturacao,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChanged;

  const _AdjustmentSlider({
    required this.label,
    required this.value,
    required this.onChangeStart,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          value: value,
          min: -1,
          max: 1,
          divisions: 20,
          onChangeStart: onChangeStart,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
// Adjustment panel widget file
