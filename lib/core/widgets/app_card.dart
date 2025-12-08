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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // важно! совпадает с Card
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(232, 255, 216, 177).withOpacity(0.25),
              const Color.fromARGB(70, 162, 165, 240).withOpacity(0.40),
            ],
          ),
        ),

        child: Padding(
  padding: const EdgeInsets.all(12),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Фото
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 80,
          height: 80,
          color: Colors.grey.shade200,
          child: photoUrl != null
              ? Image.network(photoUrl!, fit: BoxFit.cover)
              : const Icon(
                  Icons.local_florist,
                  size: 40,
                  color: Color.fromARGB(255, 212, 10, 10),
                ),
        ),
      ),

      const SizedBox(width: 12),

      // Текст (растягивается)
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            for (var s in subtitles)
              Text(
                s,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

            if (quantity != null) ...[
              const SizedBox(height: 4),
              Text(
                'Количество: $quantity',
                style: const TextStyle(fontSize: 14),
              ),
            ]
          ],
        ),
      ),

      // Кнопки справа (фиксированная ширина)
      SizedBox(
        width: 40, // важно!
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions
              .map(
                (a) => IconButton(
                  icon: Icon(a.icon, color: a.color),
                  onPressed: a.onTap,
                ),
              )
              .toList(),
        ),
      ),
    ],
  ),
),
      ),
    );
  }
}