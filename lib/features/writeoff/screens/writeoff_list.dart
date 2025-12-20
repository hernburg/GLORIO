import 'package:flutter/material.dart';
import '../../../design/glorio_colors.dart';
import '../../../design/glorio_spacing.dart';

class WriteoffListScreen extends StatelessWidget {
  const WriteoffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlorioColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: GlorioSpacing.page,
            right: GlorioSpacing.page,
            top: MediaQuery.of(context).viewPadding.top + GlorioSpacing.page,
          ),
          child: const Text('Списания'),
        ),
      ),
    );
  }
}

