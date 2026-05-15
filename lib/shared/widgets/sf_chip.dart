// sf_chip.dart — UI implementation pending.
import 'package:flutter/material.dart';

/// Selectable chip widget. Full implementation pending.
class SFChip extends StatelessWidget {
  const SFChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Chip(label: Text(label)),
  );
}
