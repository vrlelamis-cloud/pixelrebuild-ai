import 'package:flutter_test/flutter_test.dart';
import 'package:pixelrebuild_ai/main.dart';

void main() {
  testWidgets('affiche l’écran PixelRebuild AI', (tester) async {
    await tester.pumpWidget(const PixelRebuildApp());
    expect(find.text('PixelRebuild AI'), findsOneWidget);
    expect(find.text('Choisir une image'), findsOneWidget);
  });
}
