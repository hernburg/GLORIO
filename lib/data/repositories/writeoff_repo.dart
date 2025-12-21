import 'package:flutter/foundation.dart';
import '../models/writeoff.dart';

class WriteoffRepository extends ChangeNotifier {
  final List<Writeoff> _writeoffs = [];

  List<Writeoff> get writeoffs => List.unmodifiable(_writeoffs);

  void addWriteoff(Writeoff writeoff) {
    _writeoffs.add(writeoff);
    notifyListeners();
  }

  List<Writeoff> forSupply(String supplyId) {
    return _writeoffs.where((w) => w.supplyId == supplyId).toList();
  }

  List<Writeoff> forMaterial(String materialKey) {
    return _writeoffs.where((w) => w.materialKey == materialKey).toList();
  }
}
