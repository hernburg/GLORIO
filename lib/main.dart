import 'package:flutter/material.dart';
import 'dart:ui';
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
import 'data/models/supply_item.dart';
import 'data/models/sale.dart';  // ← если будет SaleAdapter
import 'data/models/sold_ingredient.dart';
import 'data/models/category.dart';
import 'data/repositories/category_repo.dart';
import 'core/error_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ------ РЕГИСТРАЦИЯ АДАПТЕРОВ ------
  Hive.registerAdapter(RelativeAdapter());
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(IngredientAdapter());
  Hive.registerAdapter(AssembledProductAdapter());
  Hive.registerAdapter(MaterialItemAdapter());
  Hive.registerAdapter(SupplyAdapter());
  Hive.registerAdapter(SupplyItemAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SoldIngredientAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // ------ СОЗДАЕМ ЕДИНСТВЕННЫЕ ИНСТАНСЫ ------
  final authRepo = AuthRepo();
  final materialsRepo = MaterialsRepo();
  final categoryRepo = CategoryRepo();
  final showcaseRepo = ShowcaseRepo();
  final supplyRepo = SupplyRepository(materialsRepo);
  final clientsRepo = ClientsRepo();
  final salesRepo = SalesRepo();
  final writeoffRepo = WriteoffRepository();
  final errorService = ErrorService();

  // ------ РОУТЕР ------
  final appRouter = AppRouter(authRepo);

  // ------ ИНИЦИАЛИЗАЦИЯ ------
  await materialsRepo.init();
  debugPrint('materialsRepo initialized');
  await categoryRepo.init();
  debugPrint('categoryRepo initialized');
  await showcaseRepo.init();
  debugPrint('showcaseRepo initialized');
  await supplyRepo.init();
  debugPrint('supplyRepo initialized');
  await clientsRepo.init();
  debugPrint('clientsRepo initialized');
  await salesRepo.init();
  debugPrint('salesRepo initialized');
  // await writeoffRepo.init(); // если нужно

  // ------ ЗАПУСК ------
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    errorService.report(details.exceptionAsString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught async error: $error');
    debugPrintStack(stackTrace: stack);
    errorService.report(error.toString());
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authRepo),
        Provider.value(value: appRouter),
        ChangeNotifierProvider.value(value: materialsRepo),
        ChangeNotifierProvider.value(value: categoryRepo),
        ChangeNotifierProvider.value(value: showcaseRepo),
        ChangeNotifierProvider.value(value: supplyRepo),
        ChangeNotifierProvider.value(value: clientsRepo),
        ChangeNotifierProvider.value(value: salesRepo),
        ChangeNotifierProvider.value(value: writeoffRepo),
        ChangeNotifierProvider.value(value: errorService),
      ],
      child: const FlowerApp(),
    ),
  );
}