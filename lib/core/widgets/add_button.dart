import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const AddButton({
    super.key,
    required this.onTap,
    this.color = const Color.fromARGB(255, 156, 164, 255), // зелёный Monceau
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: color,
      elevation: 4,
      shape: const CircleBorder(),
      onPressed: onTap,
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    );
  }
}
