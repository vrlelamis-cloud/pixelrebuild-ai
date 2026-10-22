import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';

import '../models/picked_image.dart';

class ImageSourceException implements Exception {
  const ImageSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class ImageSourceService {
  /// Renvoie l’image choisie, ou `null` si l’utilisateur annule.
  Future<PickedImage?> pick();
}

/// Sélecteur système (file_picker). Les dimensions sont lues dans l’en-tête,
/// sans décoder toute l’image.
class FilePickerImageSource implements ImageSourceService {
  const FilePickerImageSource();

  @override
  Future<PickedImage?> pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return null;

    ui.ImmutableBuffer? buffer;
    try {
      buffer = await ui.ImmutableBuffer.fromFilePath(path);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final picked = PickedImage(
        path: path,
        name: file.name,
        width: descriptor.width,
        height: descriptor.height,
      );
      descriptor.dispose();
      return picked;
    } on Exception {
      throw const ImageSourceException(
        'Format d’image non pris en charge ou fichier illisible.',
      );
    } finally {
      buffer?.dispose();
    }
  }
}
