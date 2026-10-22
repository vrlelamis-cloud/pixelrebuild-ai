import 'package:flutter/material.dart';

import '../controllers/enhance_controller.dart';
import 'widgets/options_card.dart';
import 'widgets/result_card.dart';
import 'widgets/source_card.dart';
import 'widgets/status_banner.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.controller, super.key});

  final EnhanceController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PixelRebuild')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final message = controller.message;
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: <Widget>[
                    Text(
                      'Agrandissez vos images directement sur le téléphone. '
                      'Aucune photo n’est envoyée sur internet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SourceCard(controller: controller),
                    const SizedBox(height: 16),
                    OptionsCard(controller: controller),
                    if (message != null) ...<Widget>[
                      const SizedBox(height: 16),
                      StatusBanner(
                        message: message,
                        isError: controller.messageIsError,
                      ),
                    ],
                    if (controller.result != null) ...<Widget>[
                      const SizedBox(height: 16),
                      ResultCard(controller: controller),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
