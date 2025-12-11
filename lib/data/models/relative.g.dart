// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relative.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RelativeAdapter extends TypeAdapter<Relative> {
  @override
  final int typeId = 2;

  @override
  Relative read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Relative(
      id: fields[0] as String,
      name: fields[1] as String,
      birthday: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Relative obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthday);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelativeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
