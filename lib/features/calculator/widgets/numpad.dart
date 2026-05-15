import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Custom number pad for bill/tax entry.
/// Keys: 1-9, '.', '0', '⌫'. Plus a "Done" button.
class Numpad extends StatelessWidget {
  const Numpad({super.key, required this.onKey, required this.onDone});

  final ValueChanged<String> onKey;
  final VoidCallback onDone;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgBase,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const Text(
                  'NUMBER PAD',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onDone,
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryViolet,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Key grid ─────────────────────────────────────────
          ..._keys.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: row.map((key) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _NumpadKey(
                          label: key,
                          onTap: () => onKey(key),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),

          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Key button ────────────────────────────────────────────────────────────

class _NumpadKey extends StatefulWidget {
  const _NumpadKey({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_NumpadKey> createState() => _NumpadKeyState();
}

class _NumpadKeyState extends State<_NumpadKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isBackspace = widget.label == '⌫';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 52,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.surface3 : AppColors.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Center(
          child: isBackspace
              ? const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
