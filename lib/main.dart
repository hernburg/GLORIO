import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';

// РЕПОЗИТОРИИ
import 'data/repositories/supply_repo.dart';
import 'data/repositories/showcase_repo.dart';
import 'data/repositories/materials_repo.dart';
import 'data/repositories/sales_repo.dart';
// Добавишь остальные по мере необходимости

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaterialsRepo()),
        ChangeNotifierProvider(create: (_) => SupplyRepository()),
        ChangeNotifierProvider(create: (_) => ShowcaseRepo()),
        ChangeNotifierProvider(create: (_) => SalesRepo()),
        // Добавишь: ClientsRepo, WriteoffRepo, ReportsRepo
      ],
      child: const FlowerApp(),
    ),
  );
}
