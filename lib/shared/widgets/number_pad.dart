// number_pad.dart — UI implementation pending.
// Layout: 7 8 9 / 4 5 6 / 1 2 3 / . 0 ⌫
// Full implementation pending.
import 'package:flutter/material.dart';

/// Custom number pad widget for bill entry.
/// Full UI implementation pending.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
    required this.onDone,
  });

  /// Called with the key label ('0'–'9' or '.').
  final ValueChanged<String> onKeyPress;

  /// Called when the backspace key is pressed.
  final VoidCallback onBackspace;

  /// Called when the Done key is pressed.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
