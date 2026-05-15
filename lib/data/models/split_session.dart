import 'package:decimal/decimal.dart';
import 'package:hive/hive.dart';
import 'person.dart';
import 'split_item.dart';
import 'split_mode.dart';

part 'split_session.g.dart';

/// Represents one complete bill-splitting session.
/// All monetary values are stored as strings to avoid Decimal serialization
/// issues with Hive. Use the computed getters to get [Decimal] values.
@HiveType(typeId: 2)
class SplitSession extends HiveObject {
  /// Unique session identifier (UUID v4).
  @HiveField(0)
  final String id;

  /// Timestamp when the session was created.
  @HiveField(1)
  final DateTime createdAt;

  /// Optional human-readable label (e.g. 'Thai dinner').
  @HiveField(2)
  final String? label;

  /// Bill subtotal before tax, stored as String.
  @HiveField(3)
  final String subtotalRaw;

  /// Tax amount, stored as String.
  @HiveField(4)
  final String taxRaw;

  /// Tip percentage (e.g. '18' for 18%), stored as String.
  @HiveField(5)
  final String tipPercentageRaw;

  /// If true, tip is calculated on subtotal only (not subtotal + tax).
  @HiveField(6)
  final bool tipOnSubtotal;

  /// How the bill is divided.
  @HiveField(7)
  final SplitMode splitMode;

  /// All participants in the session.
  @HiveField(8)
  final List<Person> people;

  /// Line items, only populated when [splitMode] is [SplitMode.itemized].
  @HiveField(9)
  final List<SplitItem>? items;

  /// ISO 4217 currency code (e.g. 'USD').
  @HiveField(10)
  final String currencyCode;

  /// ID of the person who eats free (birthday feature). Null if not active.
  @HiveField(11)
  final String? freeDinerPersonId;

  SplitSession({
    required this.id,
    required this.createdAt,
    this.label,
    required this.subtotalRaw,
    required this.taxRaw,
    required this.tipPercentageRaw,
    required this.tipOnSubtotal,
    required this.splitMode,
    required this.people,
    this.items,
    required this.currencyCode,
    this.freeDinerPersonId,
  });

  /// Parsed subtotal as [Decimal].
  Decimal get subtotal => Decimal.parse(subtotalRaw);

  /// Parsed tax as [Decimal].
  Decimal get tax => Decimal.parse(taxRaw);

  /// Parsed tip percentage as [Decimal].
  Decimal get tipPercentage => Decimal.parse(tipPercentageRaw);

  /// Returns a copy with the given fields replaced.
  SplitSession copyWith({
    String? label,
    String? subtotalRaw,
    String? taxRaw,
    String? tipPercentageRaw,
    bool? tipOnSubtotal,
    SplitMode? splitMode,
    List<Person>? people,
    List<SplitItem>? items,
    String? currencyCode,
    String? freeDinerPersonId,
  }) {
    return SplitSession(
      id: id,
      createdAt: createdAt,
      label: label ?? this.label,
      subtotalRaw: subtotalRaw ?? this.subtotalRaw,
      taxRaw: taxRaw ?? this.taxRaw,
      tipPercentageRaw: tipPercentageRaw ?? this.tipPercentageRaw,
      tipOnSubtotal: tipOnSubtotal ?? this.tipOnSubtotal,
      splitMode: splitMode ?? this.splitMode,
      people: people ?? this.people,
      items: items ?? this.items,
      currencyCode: currencyCode ?? this.currencyCode,
      freeDinerPersonId: freeDinerPersonId ?? this.freeDinerPersonId,
    );
  }
}
