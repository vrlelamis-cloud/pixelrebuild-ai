/// Plan d’agrandissement : dimensions de sortie et facteur réellement applicable.
class UpscalePlan {
  const UpscalePlan({
    required this.sourceWidth,
    required this.sourceHeight,
    required this.requestedScale,
    required this.effectiveScale,
  });

  final int sourceWidth;
  final int sourceHeight;
  final int requestedScale;
  final int effectiveScale;

  int get width => sourceWidth * effectiveScale;
  int get height => sourceHeight * effectiveScale;
  int get pixels => width * height;

  /// Le facteur demandé a été réduit pour préserver la mémoire.
  bool get limited => effectiveScale < requestedScale;

  /// Un agrandissement est possible (facteur d’au moins 2×).
  bool get feasible => effectiveScale >= 2;
}

/// Calcule le facteur applicable sans dépasser un nombre maximal de pixels en sortie.
class UpscalePlanner {
  const UpscalePlanner._();

  /// 16 Mpx ≈ 64 Mo de pixels décodés : raisonnable pour un téléphone d’entrée de gamme.
  static const int defaultMaxOutputPixels = 16000000;
  static const List<int> supportedScales = <int>[2, 4, 8];

  static UpscalePlan plan({
    required int width,
    required int height,
    required int scale,
    int maxPixels = defaultMaxOutputPixels,
  }) {
    if (width <= 0 || height <= 0 || scale < 1) {
      throw ArgumentError('Dimensions ou facteur invalides');
    }
    var effective = scale;
    while (
        effective > 1 && width * effective * height * effective > maxPixels) {
      effective--;
    }
    return UpscalePlan(
      sourceWidth: width,
      sourceHeight: height,
      requestedScale: scale,
      effectiveScale: effective,
    );
  }
}
