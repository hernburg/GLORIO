// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplyItemAdapter extends TypeAdapter<SupplyItem> {
  @override
  final int typeId = 6;

  @override
  SupplyItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplyItem(
      materialKey: fields[0] as String,
      name: fields[1] as String,
      categoryId: fields[2] as String,
      categoryName: fields[3] as String,
      quantity: fields[4] as double,
      costPerUnit: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SupplyItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.materialKey)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.categoryName)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.costPerUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplyItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
