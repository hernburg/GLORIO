// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sold_ingredient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoldIngredientAdapter extends TypeAdapter<SoldIngredient> {
  @override
  final int typeId = 21;

  @override
  SoldIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoldIngredient(
      materialId: fields[0] as String,
      usedQuantity: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SoldIngredient obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.materialId)
      ..writeByte(1)
      ..write(obj.usedQuantity);
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
