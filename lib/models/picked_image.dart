/// Image choisie par l’utilisateur (chemin local + dimensions lues dans l’en-tête).
class PickedImage {
  const PickedImage({
    required this.path,
    required this.name,
    required this.width,
    required this.height,
  });

  final String path;
  final String name;
  final int width;
  final int height;
}
