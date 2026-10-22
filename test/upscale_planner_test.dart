import 'package:flutter_test/flutter_test.dart';
import 'package:pixelrebuild_ai/services/upscale_planner.dart';

void main() {
  group('UpscalePlanner', () {
    test('calcule les dimensions de sortie sans limitation', () {
      final plan = UpscalePlanner.plan(width: 800, height: 600, scale: 4);
      expect(plan.width, 3200);
      expect(plan.height, 2400);
      expect(plan.limited, isFalse);
      expect(plan.feasible, isTrue);
    });

    test('réduit le facteur pour ne pas dépasser le plafond de pixels', () {
      final plan = UpscalePlanner.plan(width: 4000, height: 3000, scale: 8);
      expect(plan.pixels, lessThanOrEqualTo(UpscalePlanner.defaultMaxOutputPixels));
      expect(plan.effectiveScale, 1);
      expect(plan.feasible, isFalse);

      final mid = UpscalePlanner.plan(width: 1500, height: 1000, scale: 8);
      expect(mid.limited, isTrue);
      expect(mid.effectiveScale, lessThan(8));
      expect(mid.pixels, lessThanOrEqualTo(UpscalePlanner.defaultMaxOutputPixels));
      expect(mid.feasible, isTrue);
    });

    test('accepte un plafond personnalisé', () {
      final plan = UpscalePlanner.plan(
        width: 100,
        height: 100,
        scale: 8,
        maxPixels: 40000,
      );
      expect(plan.effectiveScale, 2);
    });

    test('refuse des dimensions invalides', () {
      expect(
        () => UpscalePlanner.plan(width: 0, height: 10, scale: 2),
        throwsArgumentError,
      );
    });
  });
}
