import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pixelrebuild_ai/services/image_upscaler.dart';

void main() {
  late Directory dir;
  late String input;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('pixelrebuild_test');
    final image = img.Image(width: 20, height: 10);
    for (final pixel in image) {
      pixel
        ..r = pixel.x * 10
        ..g = pixel.y * 20
        ..b = 128;
    }
    input = '${dir.path}/in.png';
    File(input).writeAsBytesSync(img.encodePng(image));
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('agrandit réellement l’image dans un Isolate', () async {
    const upscaler = BicubicUpscaler();
    final task = upscaler.start(
      UpscaleRequest(
          inputPath: input, outputPath: '${dir.path}/out.png', scale: 2),
    );
    final result = await task.result;
    expect(result.width, 40);
    expect(result.height, 20);
    expect(result.scale, 2);

    final decoded = img.decodePng(File(result.path).readAsBytesSync());
    expect(decoded, isNotNull);
    expect(decoded!.width, 40);
    expect(decoded.height, 20);
  });

  test('réduit le facteur quand le plafond de pixels est dépassé', () async {
    const upscaler = BicubicUpscaler();
    final task = upscaler.start(
      UpscaleRequest(
        inputPath: input,
        outputPath: '${dir.path}/out.png',
        scale: 8,
        maxOutputPixels: 20 * 10 * 9,
      ),
    );
    final result = await task.result;
    expect(result.scale, 3);
    expect(result.width, 60);
  });

  test('signale un fichier illisible', () async {
    final bad = '${dir.path}/bad.png';
    File(bad).writeAsStringSync('pas une image');
    const upscaler = BicubicUpscaler();
    final task = upscaler.start(
      UpscaleRequest(inputPath: bad, outputPath: '${dir.path}/o.png', scale: 2),
    );
    await expectLater(task.result, throwsA(isA<UpscaleException>()));
  });

  test('l’annulation interrompt la tâche', () async {
    const upscaler = BicubicUpscaler();
    final task = upscaler.start(
      UpscaleRequest(
          inputPath: input, outputPath: '${dir.path}/c.png', scale: 2),
    )..cancel();
    await expectLater(task.result, throwsA(isA<UpscaleCancelled>()));
  });
}
