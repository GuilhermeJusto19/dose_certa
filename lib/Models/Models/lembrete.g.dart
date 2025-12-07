// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lembrete.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LembreteAdapter extends TypeAdapter<Lembrete> {
  @override
  final typeId = 0;

  @override
  Lembrete read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lembrete(
      id: fields[0] as String,
      taskId: fields[1] as String,
      taskType: fields[2] as String,
      dateTime: fields[3] as DateTime,
      title: fields[4] as String,
      description: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Lembrete obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.taskType)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LembreteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
