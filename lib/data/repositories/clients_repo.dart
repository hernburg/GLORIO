import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/client.dart';

class ClientsRepo extends ChangeNotifier {
  static const boxName = 'clientsBox';

  late Box<Client> _box;

  List<Client> get clients => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<Client>(boxName);
    notifyListeners();
  }

  void addClient(Client c) {
    _box.put(c.id, c);
    notifyListeners();
  }

  void updateClient(Client c) {
    _box.put(c.id, c);
    notifyListeners();
  }

  void removeClient(String id) {
    _box.delete(id);
    notifyListeners();
  }
}