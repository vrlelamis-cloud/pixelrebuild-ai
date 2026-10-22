import 'package:flutter/material.dart';

import 'controllers/enhance_controller.dart';
import 'core/theme.dart';
import 'ui/home_page.dart';

/// Racine de l’application. Un [controller] peut être injecté (tests).
class PixelRebuildApp extends StatefulWidget {
  const PixelRebuildApp({super.key, this.controller});

  final EnhanceController? controller;

  @override
  State<PixelRebuildApp> createState() => _PixelRebuildAppState();
}

class _PixelRebuildAppState extends State<PixelRebuildApp> {
  late final EnhanceController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? EnhanceController.standard();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PixelRebuild',
      theme: buildTheme(),
      home: HomePage(controller: _controller),
    );
  }
}
