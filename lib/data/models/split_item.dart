import 'package:decimal/decimal.dart';
import 'package:hive/hive.dart';

part 'split_item.g.dart';

/// A single line item on a receipt, used in itemized split mode.
/// [assigneeIds] lists the person IDs who share this item equally.
@HiveType(typeId: 1)
class SplitItem extends HiveObject {
  /// Unique identifier (UUID v4).
  @HiveField(0)
  final String id;

  /// Description of the item (e.g. 'Pad Thai').
  @HiveField(1)
  final String description;

  /// Price of this item, stored as String to avoid Decimal serialization issues.
  @HiveField(2)
  final String priceRaw;

  /// Person IDs who share this item. If multiple, split equally among them.
  @HiveField(3)
  final List<String> assigneeIds;

  const SplitItem({
    required this.id,
    required this.description,
    required this.priceRaw,
    required this.assigneeIds,
  });

  /// Parsed price as [Decimal].
  Decimal get price => Decimal.parse(priceRaw);

  /// Returns a new [SplitItem] with the given fields replaced.
  SplitItem copyWith({
    String? description,
    String? priceRaw,
    List<String>? assigneeIds,
  }) {
    return SplitItem(
      id: id,
      description: description ?? this.description,
      priceRaw: priceRaw ?? this.priceRaw,
      assigneeIds: assigneeIds ?? this.assigneeIds,
    );
  }

  @override
  bool operator ==(Object other) => other is SplitItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
