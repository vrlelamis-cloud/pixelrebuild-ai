import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/enhance_mode.dart';
import '../models/picked_image.dart';
import '../services/image_source_service.dart';
import '../services/image_upscaler.dart';
import '../services/result_exporter.dart';
import '../services/upscale_planner.dart';

enum EnhancePhase { idle, processing, done }

/// État et actions de l’écran principal. Les services sont injectés (testable sans plugin).
class EnhanceController extends ChangeNotifier {
  EnhanceController({
    required ImageSourceService sourceService,
    required ImageUpscaler upscaler,
    required ResultExporter exporter,
    Future<Directory> Function()? workDir,
  })  : _sourceService = sourceService,
        _upscaler = upscaler,
        _exporter = exporter,
        _workDir = workDir ?? _defaultWorkDir;

  factory EnhanceController.standard() => EnhanceController(
        sourceService: const FilePickerImageSource(),
        upscaler: const BicubicUpscaler(),
        exporter: const PlatformResultExporter(),
      );

  final ImageSourceService _sourceService;
  final ImageUpscaler _upscaler;
  final ResultExporter _exporter;
  final Future<Directory> Function() _workDir;

  PickedImage? source;
  int scale = UpscalePlanner.supportedScales.first;
  EnhanceMode mode = EnhanceMode.fast;
  EnhancePhase phase = EnhancePhase.idle;
  UpscaleResult? result;
  bool showOriginal = false;
  bool exporting = false;
  String? message;
  bool messageIsError = false;

  UpscaleTask? _task;

  static Future<Directory> _defaultWorkDir() async {
    final base = await getTemporaryDirectory();
    return Directory('${base.path}/pixelrebuild').create(recursive: true);
  }

  bool get processing => phase == EnhancePhase.processing;

  UpscalePlan? get plan {
    final image = source;
    if (image == null) return null;
    return UpscalePlanner.plan(
      width: image.width,
      height: image.height,
      scale: scale,
    );
  }

  bool get canEnhance =>
      source != null && !processing && mode.available && (plan?.feasible ?? false);

  void _notify(String? text, {bool error = false}) {
    message = text;
    messageIsError = error;
    notifyListeners();
  }

  Future<void> pickImage() async {
    if (processing) return;
    try {
      final picked = await _sourceService.pick();
      if (picked == null) return;
      _discardResult();
      source = picked;
      phase = EnhancePhase.idle;
      _notify(null);
    } on ImageSourceException catch (error) {
      _notify(error.message, error: true);
    }
  }

  void setScale(int value) {
    if (processing) return;
    scale = value;
    notifyListeners();
  }

  void setMode(EnhanceMode value) {
    if (processing) return;
    mode = value;
    notifyListeners();
  }

  void setShowOriginal({required bool value}) {
    showOriginal = value;
    notifyListeners();
  }

  Future<void> enhance() async {
    final image = source;
    if (image == null || processing) return;
    if (!mode.available) {
      _notify('Ce mode n’est pas encore disponible.', error: true);
      return;
    }
    if (!(plan?.feasible ?? false)) {
      _notify(
        'Cette image est trop grande pour être agrandie en toute sécurité.',
        error: true,
      );
      return;
    }

    _discardResult();
    phase = EnhancePhase.processing;
    _notify(null);

    try {
      final dir = await _workDir();
      final output = '${dir.path}/pixelrebuild_'
          '${DateTime.now().millisecondsSinceEpoch}.png';
      final task = _upscaler.start(
        UpscaleRequest(inputPath: image.path, outputPath: output, scale: scale),
      );
      _task = task;
      final done = await task.result;
      result = done;
      showOriginal = false;
      phase = EnhancePhase.done;
      _notify(
        done.scale < scale
            ? 'Facteur limité à ${done.scale}× pour préserver la mémoire.'
            : null,
      );
    } on UpscaleCancelled {
      phase = EnhancePhase.idle;
      _notify('Traitement annulé.');
    } on UpscaleException catch (error) {
      phase = EnhancePhase.idle;
      _notify(error.message, error: true);
    } on Exception catch (error) {
      phase = EnhancePhase.idle;
      _notify('Erreur inattendue : $error', error: true);
    } finally {
      _task = null;
    }
  }

  void cancel() => _task?.cancel();

  Future<void> saveToGallery() async {
    final current = result;
    if (current == null || exporting) return;
    exporting = true;
    notifyListeners();
    try {
      await _exporter.saveToGallery(current.path);
      _notify('Image enregistrée dans l’album PixelRebuild.');
    } on ExportException catch (error) {
      _notify(error.message, error: true);
    } finally {
      exporting = false;
      notifyListeners();
    }
  }

  Future<void> share() async {
    final current = result;
    if (current == null) return;
    try {
      await _exporter.share(current.path);
    } on ExportException catch (error) {
      _notify(error.message, error: true);
    }
  }

  void _discardResult() {
    final current = result;
    result = null;
    if (current == null) return;
    try {
      final file = File(current.path);
      if (file.existsSync()) file.deleteSync();
    } on FileSystemException {
      // Nettoyage au mieux.
    }
  }

  @override
  void dispose() {
    _task?.cancel();
    _discardResult();
    super.dispose();
  }
}
