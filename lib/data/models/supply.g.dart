// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplyAdapter extends TypeAdapter<Supply> {
  @override
  final int typeId = 7;

  @override
  Supply read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Supply(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      items: (fields[2] as List).cast<SupplyItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, Supply obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.items);
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
