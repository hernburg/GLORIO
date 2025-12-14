// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sold_ingredient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoldIngredientAdapter extends TypeAdapter<SoldIngredient> {
  @override
  final int typeId = 23;

  @override
  SoldIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoldIngredient(
      materialKey: fields[0] as String,
      quantity: fields[1] as double,
      costPerUnit: fields[2] as double,
      materialName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SoldIngredient obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.materialKey)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.costPerUnit)
      ..writeByte(3)
      ..write(obj.materialName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoldIngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
