import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Lightweight image helper that supports network/file/empty placeholder.
class AppImage extends StatelessWidget {
  const AppImage.square(this.url, {super.key, this.size = 72});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final provider = _resolveProvider();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: provider == null
            ? Icon(Icons.photo, size: size * 0.4, color: Colors.grey.shade400)
            : Image(
                image: provider,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  ImageProvider? _resolveProvider() {
    if (url == null || url!.isEmpty) return null;
    final uri = Uri.tryParse(url!);
    if (uri != null && uri.scheme.startsWith('http')) {
      return NetworkImage(url!);
    }
    if (!kIsWeb) {
      final file = File(url!);
      if (file.existsSync()) return FileImage(file);
    }
    return null;
  }
}
