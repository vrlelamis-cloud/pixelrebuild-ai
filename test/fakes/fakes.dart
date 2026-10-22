import 'dart:async';
import 'dart:io';

import 'package:pixelrebuild_ai/models/picked_image.dart';
import 'package:pixelrebuild_ai/services/image_source_service.dart';
import 'package:pixelrebuild_ai/services/image_upscaler.dart';
import 'package:pixelrebuild_ai/services/result_exporter.dart';

class FakeSource implements ImageSourceService {
  PickedImage? next;
  Object? error;

  @override
  Future<PickedImage?> pick() async {
    final failure = error;
    if (failure != null) throw failure;
    return next;
  }
}

class FakeUpscaler implements ImageUpscaler {
  Object? error;
  int? forcedScale;
  UpscaleRequest? lastRequest;
  Completer<UpscaleResult>? pending;

  @override
  UpscaleTask start(UpscaleRequest request) {
    lastRequest = request;
    final completer = Completer<UpscaleResult>();
    pending = completer;
    final failure = error;
    if (failure != null) {
      completer.completeError(failure);
    } else {
      File(request.outputPath).writeAsBytesSync(<int>[1, 2, 3]);
      final scale = forcedScale ?? request.scale;
      completer.complete(
        UpscaleResult(
          path: request.outputPath,
          width: 100 * scale,
          height: 50 * scale,
          sourceWidth: 100,
          sourceHeight: 50,
          scale: scale,
        ),
      );
    }
    return UpscaleTask(
      result: completer.future,
      cancel: () {
        if (!completer.isCompleted) {
          completer.completeError(const UpscaleCancelled());
        }
      },
    );
  }
}

class FakeExporter implements ResultExporter {
  final List<String> saved = <String>[];
  final List<String> shared = <String>[];
  Object? error;

  @override
  Future<void> saveToGallery(String path) async {
    final failure = error;
    if (failure != null) throw failure;
    saved.add(path);
  }

  @override
  Future<void> share(String path) async {
    shared.add(path);
  }
}
