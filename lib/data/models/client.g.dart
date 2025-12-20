// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RelativeAdapter extends TypeAdapter<Relative> {
  @override
  final int typeId = 1;

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

class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 2;

  @override
  Client read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Client(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      birthday: fields[3] as String?,
      relatives: (fields[4] as List?)?.cast<Relative>() ?? const [],
      cashbackPercent: (fields[5] as num?)?.toDouble() ?? 0,
      pointsBalance: (fields[6] as num?)?.toInt() ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.birthday)
      ..writeByte(4)
      ..write(obj.relatives)
      ..writeByte(5)
      ..write(obj.cashbackPercent)
      ..writeByte(6)
      ..write(obj.pointsBalance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
