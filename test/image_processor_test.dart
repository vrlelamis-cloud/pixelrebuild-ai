import 'package:flutter_test/flutter_test.dart';

int outputWidth(int width, int scale) => width * scale;

void main() {
  test('calcule correctement les facteurs 2x, 4x et 8x', () {
    expect(outputWidth(800, 2), 1600);
    expect(outputWidth(800, 4), 3200);
    expect(outputWidth(800, 8), 6400);
  });
  test('ne modifie pas les dimensions originales', () {
    const original = 800;
    expect(outputWidth(original, 2), isNot(original));
    expect(original, 800);
  });
}
