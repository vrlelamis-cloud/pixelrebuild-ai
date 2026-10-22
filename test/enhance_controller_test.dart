import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixelrebuild_ai/controllers/enhance_controller.dart';
import 'package:pixelrebuild_ai/models/enhance_mode.dart';
import 'package:pixelrebuild_ai/models/picked_image.dart';
import 'package:pixelrebuild_ai/services/image_source_service.dart';
import 'package:pixelrebuild_ai/services/image_upscaler.dart';
import 'package:pixelrebuild_ai/services/result_exporter.dart';

import 'fakes/fakes.dart';

void main() {
  late Directory dir;
  late FakeSource source;
  late FakeUpscaler upscaler;
  late FakeExporter exporter;
  late EnhanceController controller;

  const photo = PickedImage(path: '/tmp/a.jpg', name: 'a.jpg', width: 100, height: 50);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('pixelrebuild_ctrl');
    source = FakeSource()..next = photo;
    upscaler = FakeUpscaler();
    exporter = FakeExporter();
    controller = EnhanceController(
      sourceService: source,
      upscaler: upscaler,
      exporter: exporter,
      workDir: () async => dir,
    );
  });

  tearDown(() {
    controller.dispose();
    dir.deleteSync(recursive: true);
  });

  test('état initial : rien à améliorer', () {
    expect(controller.canEnhance, isFalse);
    expect(controller.plan, isNull);
  });

  test('choisir une image active le bouton et calcule le plan', () async {
    await controller.pickImage();
    expect(controller.source, photo);
    expect(controller.canEnhance, isTrue);
    controller.setScale(4);
    expect(controller.plan!.width, 400);
  });

  test('un mode IA indisponible bloque le traitement', () async {
    await controller.pickImage();
    controller.setMode(EnhanceMode.standard);
    expect(controller.canEnhance, isFalse);
    await controller.enhance();
    expect(controller.phase, EnhancePhase.idle);
    expect(controller.messageIsError, isTrue);
    expect(upscaler.lastRequest, isNull);
  });

  test('améliorer produit un résultat', () async {
    await controller.pickImage();
    await controller.enhance();
    expect(controller.phase, EnhancePhase.done);
    expect(controller.result!.width, 200);
    expect(File(controller.result!.path).existsSync(), isTrue);
  });

  test('signale quand le facteur a été limité', () async {
    await controller.pickImage();
    controller.setScale(8);
    upscaler.forcedScale = 3;
    await controller.enhance();
    expect(controller.message, contains('limité à 3×'));
    expect(controller.messageIsError, isFalse);
  });

  test('une erreur de traitement est affichée', () async {
    await controller.pickImage();
    upscaler.error = const UpscaleException('boum');
    await controller.enhance();
    expect(controller.phase, EnhancePhase.idle);
    expect(controller.message, 'boum');
    expect(controller.messageIsError, isTrue);
    expect(controller.result, isNull);
  });

  test('une image illisible au choix est signalée', () async {
    source.error = const ImageSourceException('illisible');
    await controller.pickImage();
    expect(controller.message, 'illisible');
    expect(controller.source, isNull);
  });

  test('l’annulation remet l’état au repos', () async {
    await controller.pickImage();
    upscaler.error = const UpscaleCancelled();
    await controller.enhance();
    expect(controller.phase, EnhancePhase.idle);
    expect(controller.message, 'Traitement annulé.');
    expect(controller.messageIsError, isFalse);
  });

  test('enregistrer et partager passent par l’exporteur', () async {
    await controller.pickImage();
    await controller.enhance();
    await controller.saveToGallery();
    await controller.share();
    expect(exporter.saved, <String>[controller.result!.path]);
    expect(exporter.shared, <String>[controller.result!.path]);
    expect(controller.messageIsError, isFalse);
  });

  test('un échec d’enregistrement est signalé', () async {
    await controller.pickImage();
    await controller.enhance();
    exporter.error = const ExportException('plein');
    await controller.saveToGallery();
    expect(controller.message, 'plein');
    expect(controller.messageIsError, isTrue);
  });

  test('choisir une autre image supprime l’ancien résultat', () async {
    await controller.pickImage();
    await controller.enhance();
    final old = controller.result!.path;
    await controller.pickImage();
    expect(controller.result, isNull);
    expect(File(old).existsSync(), isFalse);
  });
}
