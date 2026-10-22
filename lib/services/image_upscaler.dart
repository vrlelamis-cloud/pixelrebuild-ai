import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;

import 'upscale_planner.dart';

class UpscaleRequest {
  const UpscaleRequest({
    required this.inputPath,
    required this.outputPath,
    required this.scale,
    this.maxOutputPixels = UpscalePlanner.defaultMaxOutputPixels,
  });

  final String inputPath;
  final String outputPath;
  final int scale;
  final int maxOutputPixels;
}

class UpscaleResult {
  const UpscaleResult({
    required this.path,
    required this.width,
    required this.height,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.scale,
  });

  final String path;
  final int width;
  final int height;
  final int sourceWidth;
  final int sourceHeight;

  /// Facteur réellement appliqué (peut être inférieur au facteur demandé).
  final int scale;
}

class UpscaleException implements Exception {
  const UpscaleException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UpscaleCancelled implements Exception {
  const UpscaleCancelled();
}

/// Tâche en cours : résultat asynchrone + possibilité d’annuler.
class UpscaleTask {
  const UpscaleTask({required this.result, required this.cancel});

  final Future<UpscaleResult> result;
  final void Function() cancel;
}

abstract interface class ImageUpscaler {
  UpscaleTask start(UpscaleRequest request);
}

/// Agrandissement bicubique CPU, exécuté dans un Isolate pour ne jamais bloquer l’interface.
class BicubicUpscaler implements ImageUpscaler {
  const BicubicUpscaler();

  @override
  UpscaleTask start(UpscaleRequest request) {
    final completer = Completer<UpscaleResult>();
    final messages = ReceivePort();
    final exits = ReceivePort();
    final errors = ReceivePort();
    Isolate? isolate;
    var finished = false;

    void cleanup() {
      messages.close();
      exits.close();
      errors.close();
      isolate?.kill(priority: Isolate.immediate);
      isolate = null;
    }

    void fail(Object error) {
      if (finished) return;
      finished = true;
      cleanup();
      _deleteQuietly(request.outputPath);
      completer.completeError(error);
    }

    void succeed(UpscaleResult result) {
      if (finished) return;
      finished = true;
      cleanup();
      completer.complete(result);
    }

    messages.listen((dynamic message) {
      if (message is! List<Object?> || message.isEmpty) return;
      if (message[0] == 'ok') {
        succeed(
          UpscaleResult(
            path: message[1]! as String,
            width: message[2]! as int,
            height: message[3]! as int,
            sourceWidth: message[4]! as int,
            sourceHeight: message[5]! as int,
            scale: message[6]! as int,
          ),
        );
      } else {
        fail(UpscaleException(message[1]! as String));
      }
    });
    errors.listen((dynamic error) {
      fail(UpscaleException('Échec du traitement : $error'));
    });
    exits.listen((dynamic _) {
      fail(
        const UpscaleException(
          'Traitement interrompu, probablement faute de mémoire. '
          'Essayez un facteur plus petit.',
        ),
      );
    });

    Isolate.spawn<_Job>(
      _entry,
      _Job(messages.sendPort, request),
      onError: errors.sendPort,
      onExit: exits.sendPort,
    ).then<void>(
      (spawned) {
        isolate = spawned;
        if (finished) spawned.kill(priority: Isolate.immediate);
      },
      onError: (Object error) {
        fail(UpscaleException('Impossible de démarrer le traitement : $error'));
      },
    );

    return UpscaleTask(
      result: completer.future,
      cancel: () => fail(const UpscaleCancelled()),
    );
  }
}

void _deleteQuietly(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  } on FileSystemException {
    // Nettoyage au mieux : on ignore une suppression impossible.
  }
}

class _Job {
  const _Job(this.port, this.request);

  final SendPort port;
  final UpscaleRequest request;
}

void _entry(_Job job) {
  final port = job.port;
  try {
    final request = job.request;
    final bytes = File(request.inputPath).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      port.send(
          <Object>['error', 'Image illisible ou format non pris en charge.']);
      return;
    }
    final source = img.bakeOrientation(decoded);
    final plan = UpscalePlanner.plan(
      width: source.width,
      height: source.height,
      scale: request.scale,
      maxPixels: request.maxOutputPixels,
    );
    if (!plan.feasible) {
      port.send(<Object>[
        'error',
        'Cette image est trop grande pour être agrandie en toute sécurité.',
      ]);
      return;
    }
    final resized = img.copyResize(
      source,
      width: plan.width,
      height: plan.height,
      interpolation: img.Interpolation.cubic,
    );
    File(request.outputPath).writeAsBytesSync(
      img.encodePng(resized, level: 3),
      flush: true,
    );
    port.send(<Object>[
      'ok',
      request.outputPath,
      resized.width,
      resized.height,
      source.width,
      source.height,
      plan.effectiveScale,
    ]);
  } on Object catch (error) {
    port.send(<Object>['error', 'Échec du traitement : $error']);
  }
}
