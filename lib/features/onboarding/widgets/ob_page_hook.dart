import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Onboarding page 1 — "Split bills the fair way."
/// Shows a receipt mockup with floating person avatars.
class ObPageHook extends StatefulWidget {
  const ObPageHook({super.key, required this.isActive});

  /// Whether this page is the currently visible page.
  final bool isActive;

  @override
  State<ObPageHook> createState() => _ObPageHookState();
}

class _ObPageHookState extends State<ObPageHook>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final h = constraints.maxHeight;
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── Receipt card ────────────────────────────────────
          Positioned(
            top: h * 0.08,
            child: _ReceiptCard(),
          )
              .animate(target: widget.isActive ? 1 : 0)
              .fade(duration: 500.ms, delay: 100.ms)
              .slideY(
                  begin: -0.12,
                  end: 0,
                  duration: 550.ms,
                  delay: 100.ms,
                  curve: Curves.easeOutCubic),

          // ── Alex avatar (top-left) ──────────────────────────
          Positioned(
            top: h * 0.02,
            left: 24,
            child: _PersonAvatar(
              initial: 'A',
              name: 'Alex',
              amount: '\$30',
              gradient: const LinearGradient(
                colors: [Color(0xFF9B7FFF), Color(0xFF6A3FE0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              floatOffset: _buildFloat(_floatCtrl, phase: 0),
            ),
          )
              .animate(target: widget.isActive ? 1 : 0)
              .fade(duration: 400.ms, delay: 350.ms)
              .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 450.ms,
                  delay: 350.ms,
                  curve: Curves.elasticOut),

          // ── Jess avatar (top-right) ─────────────────────────
          Positioned(
            top: h * 0.02,
            right: 24,
            child: _PersonAvatar(
              initial: 'J',
              name: 'Jess',
              amount: '\$48',
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF9F43)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              floatOffset: _buildFloat(_floatCtrl, phase: 1.2),
              labelAbove: true,
            ),
          )
              .animate(target: widget.isActive ? 1 : 0)
              .fade(duration: 400.ms, delay: 480.ms)
              .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 450.ms,
                  delay: 480.ms,
                  curve: Curves.elasticOut),

          // ── Sam avatar (bottom-right) ───────────────────────
          Positioned(
            bottom: h * 0.04,
            right: 24,
            child: _PersonAvatar(
              initial: 'S',
              name: 'Sam',
              amount: '\$52',
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4AA), Color(0xFF2BA88A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              floatOffset: _buildFloat(_floatCtrl, phase: 2.1),
              labelAbove: true,
            ),
          )
              .animate(target: widget.isActive ? 1 : 0)
              .fade(duration: 400.ms, delay: 600.ms)
              .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 450.ms,
                  delay: 600.ms,
                  curve: Curves.elasticOut),
        ],
      );
    });
  }

  /// Builds a vertical float offset using a sine-wave based on [phase].
  Animation<double> _buildFloat(AnimationController ctrl,
      {required double phase}) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -8)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -8, end: 0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: Interval(
          (phase % (2 * 3.14159)) / (2 * 3.14159),
          1.0,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}

// ── Receipt card ────────────────────────────────────────────────────────────

class _ReceiptCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              children: [
                const Text(
                  'BISTRO 47',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1836),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Table 12  ·  7:42pm',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 10,
                    color: const Color(0xFF1A1836).withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
          // Dashed divider
          _DashedDivider(),
          // Line items
          ..._items.map((item) => _LineItem(item: item)),
          // Total divider
          _DashedDivider(),
          // Total row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1836),
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                const Text(
                  '\$130.00',
                  style: TextStyle(
                    fontFamily: '.SF Mono',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1836),
                  ),
                ),
              ],
            ),
          ),
          // Scalloped bottom
          _ReceiptBottom(),
        ],
      ),
    );
  }
}

const _items = [
  (name: 'Pasta', amount: '\$18.00', color: Color(0xFF7C5CFF)),
  (name: 'Wagyu', amount: '\$52.00', color: Color(0xFFFF6B9D)),
  (name: 'Salad', amount: '\$12.00', color: Color(0xFF00D4AA)),
  (name: 'Wine', amount: '\$34.00', color: Color(0xFF9B7FFF)),
  (name: 'Tiramisu', amount: '\$14.00', color: Color(0xFFFF9F43)),
];

class _LineItem extends StatelessWidget {
  const _LineItem({required this.item});
  final ({String name, String amount, Color color}) item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          // Colored left indicator
          Container(
            width: 3,
            height: 28,
            color: item.color,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 12,
                color: Color(0xFF1A1836),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              item.amount,
              style: const TextStyle(
                fontFamily: '.SF Mono',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1836),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashPainter(),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1836).withOpacity(0.12)
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReceiptBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 14),
      painter: _ScallopPainter(),
    );
  }
}

class _ScallopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFEEEEEE);
    final path = Path()..moveTo(0, 0);
    double x = 0;
    final r = 7.0;
    while (x < size.width) {
      path.arcToPoint(
        Offset(x + r * 2, 0),
        radius: Radius.circular(r),
        clockwise: false,
      );
      x += r * 2;
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Person avatar with name + amount label ────────────────────────────────

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.initial,
    required this.name,
    required this.amount,
    required this.gradient,
    required this.floatOffset,
    this.labelAbove = false,
  });

  final String initial;
  final String name;
  final String amount;
  final LinearGradient gradient;
  final Animation<double> floatOffset;
  final bool labelAbove;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatOffset,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, floatOffset.value),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (labelAbove) ...[
            _label(),
            const SizedBox(height: 4),
          ],
          // Circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (!labelAbove) ...[
            const SizedBox(height: 4),
            _label(),
          ],
        ],
      ),
    );
  }

  Widget _label() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: gradient.colors.first.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.colors.first.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        '$name\n$amount',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: gradient.colors.first,
          height: 1.3,
        ),
      ),
    );
  }
}
