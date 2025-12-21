import 'package:hive/hive.dart';

part 'relative.g.dart';

@HiveType(typeId: 2)
class Relative extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String birthday; // dd.mm.yyyy

  Relative({
    required this.id,
    required this.name,
    required this.birthday,
  });
}