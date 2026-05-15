// sf_card.dart — UI implementation pending.
import 'package:flutter/material.dart';

/// Base surface card widget. Full implementation pending.
enum SFCardTint { none, violet, coral, mint, elevated }

class SFCard extends StatelessWidget {
  const SFCard({
    super.key,
    required this.child,
    this.tint = SFCardTint.none,
    this.padding,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final SFCardTint tint;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => child;
}
