import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/client.dart';
import '../data/models/assembled_product.dart';
import '../data/models/ingredient.dart';
import '../data/models/materialitem.dart';
import '../data/models/supply.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ClientAdapter());
    Hive.registerAdapter(IngredientAdapter());
    Hive.registerAdapter(AssembledProductAdapter());
    Hive.registerAdapter(MaterialItemAdapter());
    Hive.registerAdapter(SupplyAdapter());
  }
}