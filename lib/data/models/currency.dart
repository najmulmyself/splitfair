/// Represents a currency available in the currency selector.
class Currency {
  /// ISO 4217 currency code (e.g. 'USD').
  final String code;

  /// Currency symbol (e.g. '\$', '৳').
  final String symbol;

  /// Full currency name (e.g. 'US Dollar').
  final String name;

  /// Country flag emoji (e.g. '🇺🇸').
  final String flag;

  /// Number of decimal places for this currency (usually 2, 0 for JPY).
  final int decimalPlaces;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    this.decimalPlaces = 2,
  });

  /// Deserialize from a JSON map (as loaded from currencies.json).
  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    code: json['code'] as String,
    symbol: json['symbol'] as String,
    name: json['name'] as String,
    flag: json['flag'] as String,
    decimalPlaces: (json['decimalPlaces'] as int?) ?? 2,
  );

  /// Serialize to a JSON map.
  Map<String, dynamic> toJson() => {
    'code': code,
    'symbol': symbol,
    'name': name,
    'flag': flag,
    'decimalPlaces': decimalPlaces,
  };

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$flag $code — $name';
}
