import 'package:flutter/material.dart';
import '../../design/glorio_colors.dart';
import '../../design/glorio_radius.dart';
import '../../design/glorio_shadows.dart';

class MiniBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: GlorioColors.card,
          borderRadius: BorderRadius.circular(GlorioRadius.small),
          boxShadow: GlorioShadows.card,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(GlorioRadius.small),
          child: InkWell(
            borderRadius: BorderRadius.circular(GlorioRadius.small),
            onTap: onTap,
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: GlorioColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
