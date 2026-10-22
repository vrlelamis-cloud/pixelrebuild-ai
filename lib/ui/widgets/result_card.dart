import 'dart:io';

import 'package:flutter/material.dart';

import '../../controllers/enhance_controller.dart';
import '../../core/format.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({required this.controller, super.key});

  final EnhanceController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.result;
    final source = controller.source;
    if (result == null) return const SizedBox.shrink();
    final original = controller.showOriginal;
    final path = (original && source != null) ? source.path : result.path;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Résultat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: false, label: Text('Résultat')),
                ButtonSegment<bool>(value: true, label: Text('Original')),
              ],
              selected: <bool>{controller.showOriginal},
              onSelectionChanged: (selection) =>
                  controller.setShowOriginal(value: selection.first),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: original ? 'Image originale' : 'Image agrandie',
              image: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: Image.file(
                    File(path),
                    cacheWidth: 1080,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Aperçu indisponible.'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${formatDimensions(result.sourceWidth, result.sourceHeight)} → '
              '${formatDimensions(result.width, result.height)} '
              '(×${result.scale})',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: controller.exporting ? null : controller.saveToGallery,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Enregistrer dans la galerie'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: controller.share,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Partager'),
            ),
          ],
        ),
      ),
    );
  }
}
