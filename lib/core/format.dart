/// Formate un nombre de pixels en mégapixels, à la française (« 7,7 Mpx »).
String formatMegapixels(int pixels) {
  final value = (pixels / 1000000).toStringAsFixed(1).replaceAll('.', ',');
  return '$value Mpx';
}

/// Formate des dimensions (« 3200 × 2400 px »).
String formatDimensions(int width, int height) => '$width × $height px';
