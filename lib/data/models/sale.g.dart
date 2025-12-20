// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 22;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale(
      id: fields[0] as String,
      product: fields[1] as AssembledProduct,
      quantity: fields[2] as int,
      price: fields[3] as double,
      date: fields[4] as DateTime,
      ingredients: (fields[5] as List).cast<SoldIngredient>(),
      soldBy: fields[8] as String,
      usedPoints: (fields[9] as num?)?.toInt() ?? 0,
      finalTotal: (fields[10] as num?)?.toDouble(),
      paymentMethod: (fields[11] as String?) ?? 'Наличные',
      clientId: fields[6] as String?,
      clientName: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
  ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.product)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.ingredients)
      ..writeByte(6)
      ..write(obj.clientId)
      ..writeByte(7)
      ..write(obj.clientName)
      ..writeByte(8)
    ..write(obj.soldBy)
    ..writeByte(9)
    ..write(obj.usedPoints)
    ..writeByte(10)
    ..write(obj.finalTotal)
    ..writeByte(11)
    ..write(obj.paymentMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
