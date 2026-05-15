// sf_avatar.dart — UI implementation pending.
import 'package:flutter/material.dart';

/// Person avatar with gradient background. Full implementation pending.
class SFAvatar extends StatelessWidget {
  const SFAvatar({
    super.key,
    required this.name,
    required this.colorIndex,
    this.size = 44.0,
  });

  final String name;
  final int colorIndex;
  final double size;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
    ),
  );
}
