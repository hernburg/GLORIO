// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assembled_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssembledProductAdapter extends TypeAdapter<AssembledProduct> {
  @override
  final int typeId = 4;

  @override
  AssembledProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssembledProduct(
      id: fields[0] as String?,
      name: fields[1] as String,
      photoUrl: fields[2] as String?,
      ingredients: (fields[3] as List).cast<Ingredient>(),
      costPrice: fields[4] as double,
      sellingPrice: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AssembledProduct obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.photoUrl)
      ..writeByte(3)
      ..write(obj.ingredients)
      ..writeByte(4)
      ..write(obj.costPrice)
      ..writeByte(5)
      ..write(obj.sellingPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssembledProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
