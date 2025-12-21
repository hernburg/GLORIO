import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 24)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isArchived;

  Category({required this.id, required this.name, this.isArchived = false});

  Category copyWith({String? id, String? name, bool? isArchived}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
