import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 24)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  Category({required this.id, required this.name});
}
