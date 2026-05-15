// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitItemAdapter extends TypeAdapter<SplitItem> {
  @override
  final int typeId = 1;

  @override
  SplitItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitItem(
      id: fields[0] as String,
      description: fields[1] as String,
      priceRaw: fields[2] as String,
      assigneeIds: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SplitItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.priceRaw)
      ..writeByte(3)
      ..write(obj.assigneeIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
