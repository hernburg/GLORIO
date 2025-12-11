import 'package:flower_accounting_app/data/repositories/materials_repo.dart';
import 'package:flower_accounting_app/data/repositories/showcase_repo.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/repositories/supply_repo.dart';
import '../../data/repositories/clients_repo.dart';
import '../../data/repositories/loyalty_repo.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => SupplyRepository()),
    ChangeNotifierProvider(create: (_) => ClientsRepo()),
    ChangeNotifierProvider(create: (_) => LoyaltyRepository()),
    ChangeNotifierProvider(create: (_) => ShowcaseRepo()),
    ChangeNotifierProvider(create: (_) => MaterialsRepo()),
  ];
}

