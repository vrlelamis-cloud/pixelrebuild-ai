import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelrebuild_ai/controllers/enhance_controller.dart';
import 'package:pixelrebuild_ai/core/theme.dart';
import 'package:pixelrebuild_ai/ui/home_page.dart';

import 'fakes/fakes.dart';

void main() {
  testWidgets('l’écran d’accueil propose de choisir une image', (tester) async {
    final dir = Directory.systemTemp.createTempSync('pixelrebuild_ui');
    addTearDown(() => dir.deleteSync(recursive: true));
    final controller = EnhanceController(
      sourceService: FakeSource(),
      upscaler: FakeUpscaler(),
      exporter: FakeExporter(),
      workDir: () async => dir,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(theme: buildTheme(), home: HomePage(controller: controller)),
    );

    expect(find.text('PixelRebuild'), findsOneWidget);
    expect(find.text('Choisir une image'), findsOneWidget);
    expect(find.text('Aucune image choisie.'), findsOneWidget);
    expect(find.text('2×'), findsOneWidget);
    expect(find.text('8×'), findsOneWidget);

    final enhance = find.ancestor(
      of: find.text('Améliorer l’image'),
      matching: find.bySubtype<FilledButton>(),
    );
    expect(enhance, findsOneWidget);
    expect(tester.widget<FilledButton>(enhance).onPressed, isNull);
  });
}
