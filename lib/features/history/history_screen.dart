import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/person.dart';
import '../../data/models/split_result.dart';
import '../../data/models/split_session.dart';
import '../../domain/calculators/result_calculator.dart';
import 'history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _expandedIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessions = ref.read(historyNotifierProvider);
      if (sessions.isNotEmpty) {
        setState(() => _expandedIds.add(sessions.first.id));
      }
    });
  }

  void _toggleExpand(String id) {
    Haptics.selection();
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  Future<bool?> _confirmDelete(SplitSession session) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Split?'),
        content: Text(
          'Remove "${session.label?.isNotEmpty == true ? session.label! : 'Split Session'}" from history?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(historyNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.bgBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HistoryAppBar(),
            if (sessions.isNotEmpty) _AnalyticsRow(sessions: sessions),
            Expanded(
              child: sessions.isEmpty
                  ? const _EmptyState()
                  : _SessionList(
                      sessions: sessions,
                      expandedIds: _expandedIds,
                      onToggle: _toggleExpand,
                      onConfirmDelete: _confirmDelete,
                      onDelete: (session) async {
                        Haptics.impact();
                        await ref
                            .read(historyNotifierProvider.notifier)
                            .delete(session.id);
                        _expandedIds.remove(session.id);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HistoryAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            behavior: HitTestBehavior.opaque,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: AppColors.primaryViolet, size: 24),
                Text(
                  'SplitFair',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 17,
                    color: AppColors.primaryViolet,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Past Splits',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 20 splits — stored on your iPhone',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 14,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  const _SessionList({
    required this.sessions,
    required this.expandedIds,
    required this.onToggle,
    required this.onConfirmDelete,
    required this.onDelete,
  });

  final List<SplitSession> sessions;
  final Set<String> expandedIds;
  final ValueChanged<String> onToggle;
  final Future<bool?> Function(SplitSession) onConfirmDelete;
  final ValueChanged<SplitSession> onDelete;

  static const _adIndex = 3;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    for (int i = 0; i < sessions.length; i++) {
      if (i == _adIndex) {
        items.add(const _AdSlot());
        items.add(const SizedBox(height: 12));
      }
      final session = sessions[i];
      items.add(
        Dismissible(
          key: ValueKey(session.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => onConfirmDelete(session),
          onDismissed: (_) => onDelete(session),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 24),
          ),
          child: _SessionCard(
            session: session,
            isExpanded: expandedIds.contains(session.id),
            onTap: () => onToggle(session.id),
          ),
        ),
      );
      items.add(const SizedBox(height: 12));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: items,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.isExpanded,
    required this.onTap,
  });

  final SplitSession session;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final result = ResultCalculator.compute(session);
    final title =
        session.label?.isNotEmpty == true ? session.label! : 'Split Session';
    final fmt = NumberFormat.simpleCurrency(name: session.currencyCode);
    final totalStr = fmt.format(result.grandTotal.toDouble());

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.borderDefault),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _DateBadge(date: session.createdAt),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: '.SF Pro Display',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _AvatarStack(people: session.people),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalStr,
                        style: TextStyle(
                          fontFamily: '.SF Pro Display',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Text(
                        '${session.people.length} ${session.people.length == 1 ? 'person' : 'people'}',
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Divider(
                  height: 1, thickness: 0.5, color: context.colors.borderDefault),
              ...result.perPerson.asMap().entries.map((e) => _PersonRow(
                    result: e.value,
                    currencySymbol: fmt.currencySymbol,
                    isLast: e.key == result.perPerson.length - 1,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;

    Widget content;
    if (diff == 0) {
      content = Text(
        'TODAY',
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: context.colors.textSecondary,
          letterSpacing: 0.4,
        ),
      );
    } else if (diff == 1) {
      content = FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'YESTER\nDAY',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: context.colors.textSecondary,
            letterSpacing: 0.3,
            height: 1.3,
          ),
        ),
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            '${date.day}',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      );
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: context.colors.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: content),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.people});
  final List<Person> people;

  static const _maxVisible = 4;
  static const _size = 24.0;
  static const _step = 16.0; // size - overlap(8)

  @override
  Widget build(BuildContext context) {
    final gradients = AppColors.personGradients;
    final visible = people.take(_maxVisible).toList();
    final overflow = people.length - _maxVisible;
    final slotCount = visible.length + (overflow > 0 ? 1 : 0);
    final totalWidth = _size + (slotCount - 1) * _step;

    return SizedBox(
      height: _size,
      width: totalWidth,
      child: Stack(
        children: [
          ...visible.asMap().entries.map((e) {
            final i = e.key;
            final person = e.value;
            final g = gradients[person.colorIndex % gradients.length];
            return Positioned(
              left: i * _step,
              child: _Avatar(
                initial:
                    person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                gradient: g,
              ),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: visible.length * _step,
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.surface3,
                  border: Border.all(color: context.colors.surface1, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.gradient});
  final String initial;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [gradient[0], gradient[1]],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: context.colors.surface1, width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontFamily: '.SF Pro Display',
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.result,
    required this.currencySymbol,
    required this.isLast,
  });

  final SplitResult result;
  final String currencySymbol;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final gradients = AppColors.personGradients;
    final g = gradients[result.person.colorIndex % gradients.length];
    final initial = result.person.name.isNotEmpty
        ? result.person.name[0].toUpperCase()
        : '?';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [g[0], g[1]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.person.name,
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 15,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$currencySymbol${result.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 54,
            color: context.colors.borderDefault,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AdSlot extends StatelessWidget {
  const _AdSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A2F),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Center(
                child: Icon(Icons.bolt_rounded,
                    color: Color(0xFF4CD964), size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try Lemon Wallet',
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Send money — no fees, no signup hassle.',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: context.colors.surface3,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'AD',
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.colors.surface1,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.borderDefault),
              ),
              child: const Center(
                child: Text('\uD83E\uDDFE', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No splits yet',
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed bill splits will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Analytics row ─────────────────────────────────────────────────────────

class _AnalyticsRow extends StatelessWidget {
  const _AnalyticsRow({required this.sessions});
  final List<SplitSession> sessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonth = sessions.where((s) =>
        s.createdAt.year == now.year && s.createdAt.month == now.month);

    final count = thisMonth.length;
    Decimal totalSpent = Decimal.zero;
    Decimal tipSum = Decimal.zero;
    int tipCount = 0;

    for (final s in thisMonth) {
      final result = ResultCalculator.compute(s);
      totalSpent += result.grandTotal;
      final tipPct = Decimal.tryParse(s.tipPercentageRaw);
      if (tipPct != null && tipPct > Decimal.zero) {
        tipSum += tipPct;
        tipCount++;
      }
    }

    final avgTip = tipCount > 0
        ? (tipSum / Decimal.fromInt(tipCount))
            .toDecimal(scaleOnInfinitePrecision: 1)
        : Decimal.zero;

    final currency = sessions.isNotEmpty ? sessions.first.currencyCode : 'USD';
    final monthLabel = DateFormat('MMM').format(now);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderDefault),
      ),
      child: Row(
        children: [
          _StatChip(
            label: monthLabel,
            value: '$count ${count == 1 ? 'split' : 'splits'}',
            icon: Icons.receipt_long_rounded,
          ),
          _vDivider(context),
          _StatChip(
            label: 'Spent',
            value: '$currency ${totalSpent.toStringAsFixed(0)}',
            icon: Icons.attach_money_rounded,
          ),
          _vDivider(context),
          _StatChip(
            label: 'Avg tip',
            value: '${avgTip.toStringAsFixed(0)}%',
            icon: Icons.percent_rounded,
          ),
        ],
      ),
    );
  }

  Widget _vDivider(BuildContext context) => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: context.colors.borderDefault,
      );
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 11,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
