import 'package:flutter_test/flutter_test.dart';
import 'package:pixelrebuild_ai/core/format.dart';

void main() {
  test('formatMegapixels utilise la virgule', () {
    expect(formatMegapixels(7680000), '7,7 Mpx');
    expect(formatMegapixels(16000000), '16,0 Mpx');
  });

  test('formatDimensions', () {
    expect(formatDimensions(3200, 2400), '3200 × 2400 px');
  });
}
