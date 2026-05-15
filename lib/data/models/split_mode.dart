import 'package:hive/hive.dart';

part 'split_mode.g.dart';

/// Defines how the bill is divided among participants.
@HiveType(typeId: 3)
enum SplitMode {
  /// Total divided equally among all people.
  @HiveField(0)
  equal,

  /// Each person has a custom subtotal amount they ordered.
  @HiveField(1)
  custom,

  /// Each person is assigned a percentage of the total.
  @HiveField(2)
  percentage,

  /// Each person claims specific line items (Phase 2 — Pro feature).
  @HiveField(3)
  itemized,
}
