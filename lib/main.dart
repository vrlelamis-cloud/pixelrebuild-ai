import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const PixelRebuildApp());

class PixelRebuildApp extends StatelessWidget {
  const PixelRebuildApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'PixelRebuild AI',
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0B0F19), colorSchemeSeed: const Color(0xFF4285FF), useMaterial3: true),
    home: const HomePage(),
  );
}

enum EnhanceMode { rapide, standard, maximale, anime }

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  File? source; Uint8List? output; int scale = 2; EnhanceMode mode = EnhanceMode.rapide; bool busy = false; String status = '';
  Future<void> pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null) return;
    setState(() { source = result.files.single.path == null ? null : File(result.files.single.path!); output = null; status = ''; });
  }
  Future<void> enhance() async {
    if (source == null || busy) return;
    setState(() { busy = true; status = 'Analyse et reconstruction…'; });
    try {
      final bytes = await source!.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw const FormatException('Image illisible');
      if (mode != EnhanceMode.rapide) {
        // AI modes remain explicitly gated until a verified Android model is bundled.
        throw UnsupportedError('Le moteur IA n’est pas encore embarqué. Le mode Rapide reste disponible hors ligne.');
      }
      final resized = img.copyResize(decoded, width: decoded.width * scale, height: decoded.height * scale, interpolation: img.Interpolation.cubic);
      setState(() { output = Uint8List.fromList(img.encodePng(resized)); status = '${resized.width} × ${resized.height} px'; });
    } catch (e) { setState(() { status = e.toString().replaceFirst('Unsupported operation: ', ''); }); }
    finally { setState(() => busy = false); }
  }
  Future<void> save() async {
    if (output == null) return;
    final dir = await getTemporaryDirectory(); final file = File('${dir.path}/pixelrebuild_${scale}x.png'); await file.writeAsBytes(output!);
    await Share.shareXFiles([XFile(file.path)], text: 'Image améliorée avec PixelRebuild AI');
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('PixelRebuild AI'), backgroundColor: Colors.transparent), body: ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Reconstruisez vos images', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8), const Text('Traitement local, sans envoi automatique de vos photos.', style: TextStyle(color: Color(0xFFA7B0C0))),
    const SizedBox(height: 24),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
      if (source == null) const Icon(Icons.image_search, size: 64, color: Color(0xFF4285FF)) else Image.file(source!, height: 220, fit: BoxFit.contain),
      const SizedBox(height: 16), FilledButton.icon(onPressed: busy ? null : pick, icon: const Icon(Icons.add_photo_alternate), label: const Text('Choisir une image')),
    ]))),
    const SizedBox(height: 16),
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Agrandissement', style: TextStyle(fontWeight: FontWeight.bold)), DropdownButton<int>(value: scale, isExpanded: true, items: [2,4,8].map((v) => DropdownMenuItem(value:v, child: Text('$v×'))).toList(), onChanged: busy ? null : (v) => setState(() => scale = v!)),
      const Text('Mode', style: TextStyle(fontWeight: FontWeight.bold)), DropdownButton<EnhanceMode>(value: mode, isExpanded: true, items: const [DropdownMenuItem(value: EnhanceMode.rapide, child: Text('Rapide — interpolation locale')), DropdownMenuItem(value: EnhanceMode.standard, child: Text('IA standard — bientôt disponible')), DropdownMenuItem(value: EnhanceMode.maximale, child: Text('Qualité maximale — bientôt disponible')), DropdownMenuItem(value: EnhanceMode.anime, child: Text('Anime — bientôt disponible'))], onChanged: busy ? null : (v) => setState(() => mode = v!)),
      const SizedBox(height: 8), FilledButton.icon(onPressed: source == null || busy ? null : enhance, icon: busy ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.auto_fix_high), label: Text(busy ? 'Traitement…' : 'Améliorer l’image')),
    ]))),
    if (status.isNotEmpty) Padding(padding: const EdgeInsets.only(top:16), child: Text(status, style: TextStyle(color: status.startsWith('Le moteur') ? Colors.orange : Colors.greenAccent))),
    if (output != null) ...[const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Image.memory(output!, fit: BoxFit.contain), const SizedBox(height: 12), OutlinedButton.icon(onPressed: save, icon: const Icon(Icons.share), label: const Text('Enregistrer / partager'))])))],
  ]));
}
