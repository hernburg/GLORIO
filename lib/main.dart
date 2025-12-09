import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_router.dart';
import 'app/app.dart';

import 'data/repositories/auth_repo.dart';
import 'data/repositories/materials_repo.dart';
import 'data/repositories/showcase_repo.dart';
import 'data/repositories/supply_repo.dart';
import 'data/repositories/sales_repo.dart';
import 'data/repositories/clients_repo.dart';
import 'data/repositories/writeoff_repo.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepo()),

        // AppRouter ТРЕБУЕТ authRepo → получаем его из Provider
        ChangeNotifierProxyProvider<AuthRepo, AppRouter>(
          create: (context) => AppRouter(context.read<AuthRepo>()),
          update: (context, auth, prev) => AppRouter(auth),
        ),

        ChangeNotifierProvider(create: (_) => MaterialsRepo()),
        ChangeNotifierProvider(create: (_) => ShowcaseRepo()),
        ChangeNotifierProvider(create: (_) => SupplyRepository ()),
        ChangeNotifierProvider(create: (_) => SalesRepo()),
        ChangeNotifierProvider(create: (_) => ClientsRepository()),
        ChangeNotifierProvider(create: (_) => WriteoffRepository()),
      ],
      child: const FlowerApp(),
    ),
  );
}