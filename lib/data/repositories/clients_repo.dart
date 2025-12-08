import 'package:flutter/foundation.dart';
import '../models/client.dart';

class ClientsRepository extends ChangeNotifier {
  final List<Client> _clients = [];

  List<Client> get clients => List.unmodifiable(_clients);

  void addClient(Client client) {
    _clients.add(client);
    notifyListeners();
  }

  Client? getByPhone(String phone) {
    try {
      return _clients.firstWhere((c) => c.phone == phone);
    } catch (_) {
      return null;
    }
  }
}
