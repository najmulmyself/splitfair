// animated_amount.dart — UI implementation pending.
import 'package:flutter/material.dart';

/// Count-up animated amount widget. Full implementation pending.
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.amount,
    required this.style,
    this.currencySymbol = '\$',
  });

  /// The formatted amount string to display.
  final String amount;

  /// The text style to apply.
  final TextStyle style;

  /// Currency symbol shown before the amount.
  final String currencySymbol;

  @override
  Widget build(BuildContext context) => Text('$currencySymbol$amount', style: style);
}
