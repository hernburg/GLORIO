// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplyAdapter extends TypeAdapter<Supply> {
  @override
  final int typeId = 6;

  @override
  Supply read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Supply(
      id: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as double,
      usedInBouquets: fields[3] as double,
      writtenOff: fields[4] as double,
      purchasePrice: fields[5] as double,
      supplyDate: fields[6] as DateTime,
      photoUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Supply obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.usedInBouquets)
      ..writeByte(4)
      ..write(obj.writtenOff)
      ..writeByte(5)
      ..write(obj.purchasePrice)
      ..writeByte(6)
      ..write(obj.supplyDate)
      ..writeByte(7)
      ..write(obj.photoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
