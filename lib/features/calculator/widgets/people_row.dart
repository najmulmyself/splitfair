import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/person.dart';

/// Horizontal scrollable row of person avatars + the "Add" button.
class PeopleRow extends StatelessWidget {
  const PeopleRow({
    super.key,
    required this.people,
    required this.activePersonId,
    required this.canRemove,
    required this.onAdd,
    required this.onSelect,
    required this.onLongPress,
  });

  final List<Person> people;
  final String? activePersonId;
  final bool canRemove;
  final VoidCallback onAdd;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          // ── Add button ─────────────────────────────────────
          _AddButton(onTap: onAdd).animate().fade(duration: 250.ms).scale(
              begin: const Offset(0.7, 0.7),
              duration: 350.ms,
              curve: Curves.elasticOut),
          const SizedBox(width: 12),

          // ── Person avatars ─────────────────────────────────
          ...people.asMap().entries.map((e) {
            final index = e.key;
            final person = e.value;
            final isActive = person.id == activePersonId;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _PersonAvatar(
                person: person,
                isActive: isActive,
                canRemove: canRemove,
                onTap: () => onSelect(person.id),
                onLongPress: () => onLongPress(person.id),
              ).animate(key: ValueKey(person.id)).fade(duration: 250.ms).scale(
                    begin: const Offset(0.6, 0.6),
                    duration: 400.ms,
                    delay: Duration(milliseconds: index * 50),
                    curve: Curves.elasticOut,
                  ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Add button ────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.surface2,
                border: Border.all(
                  color: context.colors.borderDefault,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: context.colors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Person avatar ─────────────────────────────────────────────────────────

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.person,
    required this.isActive,
    required this.canRemove,
    required this.onTap,
    required this.onLongPress,
  });

  final Person person;
  final bool isActive;
  final bool canRemove;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final gradients = AppColors.personGradients;
    final gradient = gradients[person.colorIndex % gradients.length];
    final initial =
        person.name.isNotEmpty ? person.name.trim()[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [gradient[0], gradient[1]],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: isActive
                          ? Colors.white.withOpacity(0.85)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: gradient[0].withOpacity(0.5),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Display',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                // Red minus badge — visible when canRemove (2+ people)
                Positioned(
                  top: -3,
                  right: -3,
                  child: AnimatedOpacity(
                    opacity: canRemove ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '−',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              person.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color:
                    isActive ? context.colors.textPrimary : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
