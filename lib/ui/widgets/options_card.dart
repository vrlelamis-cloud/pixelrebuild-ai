import 'package:flutter/material.dart';

import '../../controllers/enhance_controller.dart';
import '../../core/format.dart';
import '../../models/enhance_mode.dart';
import '../../services/upscale_planner.dart';

class OptionsCard extends StatelessWidget {
  const OptionsCard({required this.controller, super.key});

  final EnhanceController controller;

  @override
  Widget build(BuildContext context) {
    final plan = controller.plan;
    final busy = controller.processing;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Réglages', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text('Facteur d’agrandissement'),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: <ButtonSegment<int>>[
                for (final value in UpscalePlanner.supportedScales)
                  ButtonSegment<int>(value: value, label: Text('$value×')),
              ],
              selected: <int>{controller.scale},
              onSelectionChanged:
                  busy ? null : (selection) => controller.setScale(selection.first),
            ),
            const SizedBox(height: 16),
            DropdownMenu<EnhanceMode>(
              label: const Text('Mode'),
              enabled: !busy,
              expandedInsets: EdgeInsets.zero,
              initialSelection: controller.mode,
              onSelected: (value) {
                if (value != null) controller.setMode(value);
              },
              dropdownMenuEntries: <DropdownMenuEntry<EnhanceMode>>[
                for (final mode in EnhanceMode.values)
                  DropdownMenuEntry<EnhanceMode>(
                    value: mode,
                    label: mode.available ? mode.label : '${mode.label} (bientôt)',
                    enabled: mode.available,
                  ),
              ],
            ),
            if (plan != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                plan.feasible
                    ? 'Résultat estimé : '
                        '${formatDimensions(plan.width, plan.height)} '
                        '(${formatMegapixels(plan.pixels)})'
                    : 'Image trop grande pour être agrandie en toute sécurité.',
              ),
              if (plan.limited && plan.feasible)
                Text(
                  'Facteur limité à ${plan.effectiveScale}× '
                  'pour préserver la mémoire.',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
            ],
            const SizedBox(height: 16),
            if (busy) ...<Widget>[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: controller.cancel,
                icon: const Icon(Icons.close),
                label: const Text('Annuler'),
              ),
            ] else
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: controller.canEnhance ? controller.enhance : null,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Améliorer l’image'),
              ),
          ],
        ),
      ),
    );
  }
}
