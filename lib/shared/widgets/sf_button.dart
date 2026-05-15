// sf_button.dart — UI implementation pending.
import 'package:flutter/material.dart';

/// Button variants. Full implementation pending.
enum SFButtonVariant { primary, secondary, destructive }

class SFButton extends StatelessWidget {
  const SFButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SFButtonVariant.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SFButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    child: Text(label),
  );
}
