import 'dart:io';

import 'package:flutter/material.dart';

import '../../controllers/enhance_controller.dart';
import '../../core/format.dart';

class SourceCard extends StatelessWidget {
  const SourceCard({required this.controller, super.key});

  final EnhanceController controller;

  @override
  Widget build(BuildContext context) {
    final image = controller.source;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Image source',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (image == null)
              const Text('Aucune image choisie.')
            else ...<Widget>[
              Semantics(
                label: 'Aperçu de l’image source ${image.name}',
                image: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: Image.file(
                      File(image.path),
                      cacheWidth: 1080,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text('Aperçu indisponible.'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                image.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${formatDimensions(image.width, image.height)} · '
                '${formatMegapixels(image.width * image.height)}',
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: controller.processing ? null : controller.pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label:
                  Text(image == null ? 'Choisir une image' : 'Changer d’image'),
            ),
          ],
        ),
      ),
    );
  }
}
