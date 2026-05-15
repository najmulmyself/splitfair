// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitSessionAdapter extends TypeAdapter<SplitSession> {
  @override
  final int typeId = 2;

  @override
  SplitSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitSession(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      label: fields[2] as String?,
      subtotalRaw: fields[3] as String,
      taxRaw: fields[4] as String,
      tipPercentageRaw: fields[5] as String,
      tipOnSubtotal: fields[6] as bool,
      splitMode: fields[7] as SplitMode,
      people: (fields[8] as List).cast<Person>(),
      items: (fields[9] as List?)?.cast<SplitItem>(),
      currencyCode: fields[10] as String,
      freeDinerPersonId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SplitSession obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.subtotalRaw)
      ..writeByte(4)
      ..write(obj.taxRaw)
      ..writeByte(5)
      ..write(obj.tipPercentageRaw)
      ..writeByte(6)
      ..write(obj.tipOnSubtotal)
      ..writeByte(7)
      ..write(obj.splitMode)
      ..writeByte(8)
      ..write(obj.people)
      ..writeByte(9)
      ..write(obj.items)
      ..writeByte(10)
      ..write(obj.currencyCode)
      ..writeByte(11)
      ..write(obj.freeDinerPersonId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
