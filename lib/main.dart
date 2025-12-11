import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ROUTER + APP
import 'app/app_router.dart';
import 'app/app.dart';

// REPOS
import 'data/repositories/auth_repo.dart';
import 'data/repositories/materials_repo.dart';
import 'data/repositories/showcase_repo.dart';
import 'data/repositories/supply_repo.dart';
import 'data/repositories/sales_repo.dart';
import 'data/repositories/clients_repo.dart';
import 'data/repositories/writeoff_repo.dart';

// MODELS + ADAPTERS
import 'data/models/client.dart';
import 'data/models/ingredient.dart';
import 'data/models/assembled_product.dart';
import 'data/models/materialitem.dart';
import 'data/models/supply.dart';
import 'data/models/sale.dart';  // ← если будет SaleAdapter
import 'data/models/sold_ingredient.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ------ РЕГИСТРАЦИЯ АДАПТЕРОВ ------
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(AssembledProductAdapter());
  Hive.registerAdapter(MaterialItemAdapter());
  Hive.registerAdapter(SupplyAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SoldIngredientAdapter());

  // ------ СОЗДАЕМ ЕДИНСТВЕННЫЕ ИНСТАНСЫ ------
  final materialsRepo = MaterialsRepo();
  final showcaseRepo = ShowcaseRepo();
  final supplyRepo = SupplyRepository();
  final clientsRepo = ClientsRepo();
  final salesRepo = SalesRepo();
  final writeoffRepo = WriteoffRepository();

  // ------ ИНИЦИАЛИЗАЦИЯ ------
  await materialsRepo.init();
  await showcaseRepo.init();
  await supplyRepo.init();
  await clientsRepo.init();
  await salesRepo.init();
  // await writeoffRepo.init(); // если нужно

  // ------ ЗАПУСК ------
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepo()),
        Provider(
          create: (context) => AppRouter(context.read<AuthRepo>()),
        ),

        ChangeNotifierProvider.value(value: materialsRepo),
        ChangeNotifierProvider.value(value: showcaseRepo),
        ChangeNotifierProvider.value(value: supplyRepo),
        ChangeNotifierProvider.value(value: clientsRepo),
        ChangeNotifierProvider.value(value: salesRepo),
        ChangeNotifierProvider.value(value: writeoffRepo),
      ],
      child: const FlowerApp(),
    ),
  );
}