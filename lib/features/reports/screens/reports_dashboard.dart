import 'package:flutter/material.dart';
import '../../../ui/screen_content_layout.dart';

class ReportsDashboard extends StatelessWidget {
  const ReportsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentLayout(
      child: Center(child: Text("Отчёты")),
    );
  }
}
