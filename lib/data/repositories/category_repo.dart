import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryRepo extends ChangeNotifier {
  static const boxName = 'categoriesBox';

  Box<Category>? _box;
  bool _isReady = false;

  List<Category> get categories => _isReady && _box != null
      ? _box!.values.toList()
      : const [];

  Future<void> init() async {
    if (_isReady) return;
    _box = await Hive.openBox<Category>(boxName);

    if (_box!.isEmpty) {
      for (final c in _seedCategories()) {
        _box!.put(c.id, c);
      }
    }

    _isReady = true;
    notifyListeners();
  }

  Category? getById(String id) {
    if (!_isReady || _box == null) return null;
    return _box!.get(id);
  }

  Category addCategory(String name) {
    final trimmed = name.trim();
    final id = _makeSlug(trimmed);
    final uniqueId = _ensureUnique(id);
    final category = Category(id: uniqueId, name: trimmed);
    _box?.put(uniqueId, category);
    notifyListeners();
    return category;
  }

  List<Category> _seedCategories() {
    const seeds = [
      // Цветы
      'Срезанные цветы',
      'Срезанные цветы (премиум)',
      'Срезанные цветы (локальные)',
      'Срезанные цветы (импорт)',
      'Горшечные цветы',
      'Горшечные растения (нецветущие)',
      'Орхидеи (горшечные)',
      'Суккуленты',
      'Кактусы',
      'Бонсай',
      // Зелень и растительные дополнения
      'Зелень (срезанная)',
      'Декоративная зелень',
      'Эвкалипт',
      'Хвоя',
      'Сухоцветы',
      'Стабилизированные растения',
      'Мох стабилизированный',
      // Декор
      'Флористический декор',
      'Искусственные цветы',
      'Искусственная зелень',
      'Ветки декоративные',
      'Ягоды декоративные',
      'Природный декор',
      'Сезонный декор',
      // Упаковка
      'Бумага упаковочная',
      'Крафт',
      'Плёнка',
      'Коробки',
      'Шляпные коробки',
      'Корзины',
      'Кашпо',
      'Вазы',
      'Пакеты',
      // Ленты и крепёж
      'Ленты',
      'Тесьма',
      'Верёвки',
      'Шпагат',
      'Проволока',
      'Флористическая сетка',
      'Флористическая тейп-лента',
      'Резинки',
      // Расходные материалы
      'Флористическая пена (оазис)',
      'Клей флористический',
      'Скотч',
      'Плёнка техническая',
      'Подкладочные материалы',
      // Аксессуары и допродажи
      'Открытки',
      'Конверты',
      'Топперы',
      'Свечи',
      'Шоколад',
      'Мягкие игрушки',
      'Подарочные элементы',
    ];

    return seeds
        .map((name) => Category(id: _makeSlug(name), name: name))
        .toList();
  }

  String _ensureUnique(String base) {
    var candidate = base;
    var counter = 1;
    while (_box?.containsKey(candidate) == true) {
      candidate = '$base-$counter';
      counter++;
    }
    return candidate;
  }

  String _makeSlug(String input) {
    final lower = input.trim().toLowerCase();
  final slug = lower
    .replaceAll(RegExp(r'[^a-z0-9а-яё]+', caseSensitive: false), '-')
    .replaceAll(RegExp('-+'), '-')
    .replaceAll(RegExp(r'^-|-\$'), '');
    if (slug.isEmpty) return 'cat-${DateTime.now().millisecondsSinceEpoch}';
    return slug;
  }
}
