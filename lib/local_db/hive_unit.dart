import 'package:hive_flutter/hive_flutter.dart';

import 'package:flower_accounting_app/data/models/client.dart';
import 'package:flower_accounting_app/data/models/assembled_product.dart';
import 'package:flower_accounting_app/data/models/ingredient.dart';
import 'package:flower_accounting_app/data/models/materialitem.dart';
import 'package:flower_accounting_app/data/models/supply.dart';
import 'package:flower_accounting_app/data/models/sold_ingredient.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ClientAdapter());
    Hive.registerAdapter(IngredientAdapter());
    Hive.registerAdapter(AssembledProductAdapter());
    Hive.registerAdapter(MaterialItemAdapter());
    Hive.registerAdapter(SupplyAdapter());
    Hive.registerAdapter(SoldIngredientAdapter());
  }
}