// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class AppCardAction {
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   AppCardAction({
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });
// }

// class AppCard extends StatelessWidget {
//   final String title;
//   final List<String> subtitles;
//   final double? quantity; // ← ДОБАВИЛИ
//   final String? photoUrl;
//   final List<AppCardAction> actions;

//   const AppCard({
//     super.key,
//     required this.title,
//     required this.subtitles,
//     this.quantity, // ← ДОБАВИЛИ
//     this.photoUrl,
//     required this.actions,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final image = _buildImage();

//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               const Color.fromARGB(232, 255, 255, 255),
//               const Color.fromARGB(255, 245, 245, 245),
//             ],
//           ),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Фото
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: image,
//             ),
//             const SizedBox(width: 12),

//             /// Текстовая часть
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// Заголовок
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   /// Подзаголовки
//                   ...subtitles.map(
//                     (t) => Text(
//                       t,
//                       style: const TextStyle(fontSize: 14, color: Colors.black54),
//                     ),
//                   ),

//                   /// Количество — ЕСЛИ есть
//                   if (quantity != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 6),
//                       child: Text(
//                         "Остаток: $quantity",
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             /// Кнопки действий
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: actions
//                   .map(
//                     (a) => IconButton(
//                       icon: Icon(a.icon, color: a.color),
//                       onPressed: a.onTap,
//                     ),
//                   )
//                   .toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImage() {
//     const size = Size(70, 70);

//     if (photoUrl == null || photoUrl!.trim().isEmpty) {
//       return _placeholder(size);
//     }

//     final value = photoUrl!.trim();
//     if (_isNetworkUrl(value)) {
//       return _sizedImage(
//         size,
//         Image.network(
//           value,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => _placeholder(size),
//         ),
//       );
//     }

//     if (!kIsWeb) {
//       try {
//         final file = File(value);
//         if (file.existsSync()) {
//           return _sizedImage(
//             size,
//             Image.file(
//               file,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => _placeholder(size),
//             ),
//           );
//         }
//       } catch (_) {
//         return _placeholder(size);
//       }
//     }

//     return _placeholder(size);
//   }

//   Widget _sizedImage(Size size, Widget child) {
//     return SizedBox(
//       width: size.width,
//       height: size.height,
//       child: child,
//     );
//   }

//   Widget _placeholder(Size size) {
//     return _sizedImage(
//       size,
//       Container(
//         color: Colors.grey.shade200,
//         child: const Icon(Icons.image_not_supported, color: Colors.grey),
//       ),
//     );
//   }

//   bool _isNetworkUrl(String value) {
//     final uri = Uri.tryParse(value);
//     return uri != null &&
//         (uri.scheme == 'http' || uri.scheme == 'https');
//   }
// }