import 'package:flutter/material.dart';
import '../../../ui/screen_content_layout.dart';

class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContentLayout(
      child: Center(child: Text("Клиенты")),
    );
  }
}
