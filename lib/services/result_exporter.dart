import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

class ExportException implements Exception {
  const ExportException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class ResultExporter {
  Future<void> saveToGallery(String path);
  Future<void> share(String path);
}

/// Enregistrement dans la galerie (album « PixelRebuild ») et partage système.
class PlatformResultExporter implements ResultExporter {
  const PlatformResultExporter();

  @override
  Future<void> saveToGallery(String path) async {
    try {
      await Gal.putImage(path, album: 'PixelRebuild');
    } on Exception catch (error) {
      throw ExportException('Enregistrement impossible : $error');
    }
  }

  @override
  Future<void> share(String path) async {
    try {
      await Share.shareXFiles(
        <XFile>[XFile(path, mimeType: 'image/png')],
        text: 'Image agrandie avec PixelRebuild',
      );
    } on Exception catch (error) {
      throw ExportException('Partage impossible : $error');
    }
  }
}
