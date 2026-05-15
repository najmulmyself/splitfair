// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitModeAdapter extends TypeAdapter<SplitMode> {
  @override
  final int typeId = 3;

  @override
  SplitMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SplitMode.equal;
      case 1:
        return SplitMode.custom;
      case 2:
        return SplitMode.percentage;
      case 3:
        return SplitMode.itemized;
      default:
        return SplitMode.equal;
    }
  }

  @override
  void write(BinaryWriter writer, SplitMode obj) {
    switch (obj) {
      case SplitMode.equal:
        writer.writeByte(0);
        break;
      case SplitMode.custom:
        writer.writeByte(1);
        break;
      case SplitMode.percentage:
        writer.writeByte(2);
        break;
      case SplitMode.itemized:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
