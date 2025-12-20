import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Relative {
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

@HiveType(typeId: 2)
class Client {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String? birthday;

  @HiveField(4)
  final List<Relative> relatives;

  @HiveField(5)
  final double cashbackPercent;

  @HiveField(6)
  final int pointsBalance;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.birthday,
    this.relatives = const [],
    this.cashbackPercent = 0,
    this.pointsBalance = 0,
  });

  Client copyWith({
    String? name,
    String? phone,
    String? birthday,
    List<Relative>? relatives,
    double? cashbackPercent,
    int? pointsBalance,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      relatives: relatives ?? this.relatives,
      cashbackPercent: cashbackPercent ?? this.cashbackPercent,
      pointsBalance: pointsBalance ?? this.pointsBalance,
    );
  }
}