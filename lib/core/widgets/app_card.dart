import 'dart:io';
import 'package:flutter/material.dart';

class AppCardAction {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  AppCardAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class AppCard extends StatelessWidget {
  final String title;
  final List<String> subtitles;
  final double? quantity;
  final String? photoUrl;
  final List<AppCardAction> actions;

  const AppCard({
    super.key,
    required this.title,
    required this.subtitles,
    this.quantity,
    this.photoUrl,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(232, 255, 216, 177).withOpacity(0.25),
              const Color.fromARGB(70, 162, 165, 240).withOpacity(0.40),
            ],
          ),
        ),
        padding: const EdgeInsets.all(12),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhoto(),

            const SizedBox(width: 12),

            Expanded(
              child: _buildTexts(),
            ),

            const SizedBox(width: 6),

            _buildActions(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // PHOTO
  // -------------------------------------------------------------
  Widget _buildPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 80,
        height: 80,
        color: Colors.grey.shade200,
        child: _resolvePhoto(),
      ),
    );
  }

  Widget _resolvePhoto() {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return const Icon(
        Icons.local_florist,
        size: 40,
        color: Color.fromARGB(255, 212, 10, 10),
      );
    }

    // локальный файл
    final isFilePath =
        photoUrl!.startsWith('/') || photoUrl!.startsWith('file://');

    if (isFilePath) {
      return Image.file(
        File(photoUrl!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    // сетевое изображение
    return Image.network(
      photoUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  // -------------------------------------------------------------
  // TEXTS
  // -------------------------------------------------------------
  Widget _buildTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 6),

        for (var s in subtitles)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),

        if (quantity != null) ...[
          const SizedBox(height: 4),
          Text(
            'Количество: $quantity',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------
  // ACTIONS (кнопки справа)
  // -------------------------------------------------------------
  Widget _buildActions() {
    return Column(
      children: actions
          .map(
            (a) => IconButton(
              icon: Icon(a.icon, color: a.color, size: 22),
              onPressed: a.onTap,
              splashRadius: 22,
            ),
          )
          .toList(),
    );
  }
}