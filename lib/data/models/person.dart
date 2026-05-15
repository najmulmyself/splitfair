import 'package:hive/hive.dart';

part 'person.g.dart';

/// Represents a participant in a bill split.
/// [id] is a UUID v4 generated at creation time.
/// [colorIndex] maps to [AppColors.personGradients] (0–3, cycles).
/// [shareWeight] is repurposed per split mode:
///   - equal: always 1
///   - custom: person's amount in cents (e.g. 1250 = \$12.50)
///   - percentage: percentage × 100 in basis points (e.g. 3333 = 33.33%)
@HiveType(typeId: 0)
class Person extends HiveObject {
  /// Unique identifier (UUID v4).
  @HiveField(0)
  final String id;

  /// Display name, max 20 characters.
  @HiveField(1)
  final String name;

  /// Color index 0–3, maps to [AppColors.personGradients].
  @HiveField(2)
  final int colorIndex;

  /// Share weight. Interpretation depends on [SplitMode].
  @HiveField(3)
  final int shareWeight;

  const Person({
    required this.id,
    required this.name,
    required this.colorIndex,
    this.shareWeight = 1,
  });

  /// Returns a new [Person] with the given fields replaced.
  Person copyWith({String? name, int? colorIndex, int? shareWeight}) {
    return Person(
      id: id,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      shareWeight: shareWeight ?? this.shareWeight,
    );
  }

  @override
  bool operator ==(Object other) => other is Person && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Person(id: $id, name: $name)';
}
