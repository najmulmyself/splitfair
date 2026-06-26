import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

/// Small cake-emoji badge shown on an avatar marked as the free diner
/// ("Birthday Person Eats Free"). Spring scale-in when it first appears.
class FreeDinerBadge extends StatelessWidget {
  const FreeDinerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: AppColors.warmAmber,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '🎂',
          style: TextStyle(fontSize: 11, height: 1),
        ),
      ),
    ).animate().scale(
          begin: const Offset(0, 0),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.elasticOut,
        );
  }
}
