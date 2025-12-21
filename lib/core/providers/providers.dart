import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/clients_repo.dart';
import '../../data/repositories/loyalty_repo.dart';
import '../../data/repositories/materials_repo.dart';
import '../../data/repositories/showcase_repo.dart';
import '../../data/repositories/supply_repo.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => MaterialsRepo()),

    ChangeNotifierProvider(
      create: (context) => SupplyRepository(
        context.read<MaterialsRepo>(),
      ),
    ),

    ChangeNotifierProvider(create: (_) => ClientsRepo()),
    ChangeNotifierProvider(create: (_) => LoyaltyRepository()),
    ChangeNotifierProvider(create: (_) => ShowcaseRepo()),
  ];
}