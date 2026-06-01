import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/currency.dart';
import '../calculator/providers/calculator_provider.dart';
import 'currency_provider.dart';

/// Full-screen currency selector.
class CurrencySelectorSheet extends ConsumerStatefulWidget {
  const CurrencySelectorSheet({super.key});

  @override
  ConsumerState<CurrencySelectorSheet> createState() =>
      _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends ConsumerState<CurrencySelectorSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allCurrenciesProvider);
    final selectedCode = ref.watch(currencyNotifierProvider);
    final recentCodes = ref.watch(recentCurrencyCodesProvider);

    return Scaffold(
      backgroundColor: context.colors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: context.colors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Select Currency',
                      style: TextStyle(
                        fontFamily: '.SF Pro Display',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.surface1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.borderDefault),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.search_rounded,
                          color: context.colors.textTertiary, size: 18),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _query = v.trim().toLowerCase()),
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 15,
                          color: context.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search currency or country...',
                          hintStyle: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 15,
                            color: context.colors.textTertiary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 250.ms),
            ),

            // ── Currency list ────────────────────────────────
            Expanded(
              child: allAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryViolet, strokeWidth: 2),
                ),
                error: (_, __) => Center(
                  child: Text('Failed to load currencies',
                      style: TextStyle(color: context.colors.textSecondary)),
                ),
                data: (allCurrencies) {
                  final recentList = recentCodes
                      .map((code) {
                        try {
                          return allCurrencies
                              .firstWhere((c) => c.code == code);
                        } catch (_) {
                          return null;
                        }
                      })
                      .whereType<Currency>()
                      .toList();

                  final filtered = _query.isEmpty
                      ? allCurrencies
                      : allCurrencies.where((c) {
                          return c.code.toLowerCase().contains(_query) ||
                              c.name.toLowerCase().contains(_query);
                        }).toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      // Recent section (hidden when searching)
                      if (_query.isEmpty && recentList.isNotEmpty) ...[
                        _SectionHeader(label: 'RECENT'),
                        ...recentList.map((c) => _CurrencyTile(
                              currency: c,
                              isSelected: c.code == selectedCode,
                              onTap: () => _select(c.code),
                            )),
                        const SizedBox(height: 6),
                      ],

                      // All currencies section
                      _SectionHeader(
                        label: _query.isEmpty ? 'ALL CURRENCIES' : 'RESULTS',
                      ),
                      ...filtered.asMap().entries.map((e) {
                        final i = e.key;
                        return _CurrencyTile(
                          currency: e.value,
                          isSelected: e.value.code == selectedCode,
                          onTap: () => _select(e.value.code),
                          animDelay:
                              Duration(milliseconds: (i * 20).clamp(0, 300)),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(String code) {
    Haptics.selection();
    ref.read(currencyNotifierProvider.notifier).select(code);
    ref.read(calculatorNotifierProvider.notifier).setCurrency(code);
    Navigator.of(context).pop();
  }
}

// ── Section header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: context.colors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Currency tile ─────────────────────────────────────────────────────────

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.currency,
    required this.isSelected,
    required this.onTap,
    this.animDelay = Duration.zero,
  });

  final Currency currency;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animDelay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryViolet.withOpacity(0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Flag
            Text(
              currency.flag,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 14),

            // Code + name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.code,
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    currency.name,
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primaryViolet, size: 22)
            else
              const SizedBox(width: 22),
          ],
        ),
      ).animate(delay: animDelay).fade(duration: 200.ms),
    );
  }
}
