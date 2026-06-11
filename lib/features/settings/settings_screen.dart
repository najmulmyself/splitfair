import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../currency/currency_provider.dart';
import '../pro_unlock/iap_provider.dart';
import '../settings/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final iapState = ref.watch(iapNotifierProvider);
    final iapNotifier = ref.read(iapNotifierProvider.notifier);

    final currencyCode = ref.watch(currencyNotifierProvider);
    final allCurrenciesAsync = ref.watch(allCurrenciesProvider);
    final currencyFlag = allCurrenciesAsync.when(
      data: (list) {
        final m = list.where((c) => c.code == currencyCode).toList();
        return m.isEmpty ? '' : m.first.flag;
      },
      loading: () => '',
      error: (_, __) => '',
    );

    return Scaffold(
      backgroundColor: context.colors.bgBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _SectionLabel('DEFAULTS'),
                  _SettingsCard(children: [
                    _NavRow(
                      label: 'Default tip',
                      trailing: '${state.defaultTipPercentage}%',
                      onTap: () => _showTipPicker(
                          context, state.defaultTipPercentage, notifier),
                    ),
                    const _CardDivider(),
                    _NavRow(
                      label: 'Default currency',
                      trailing: '$currencyFlag $currencyCode',
                      onTap: () => context.push(AppRoutes.currency),
                    ),
                    const _CardDivider(),
                    _TipOnRow(
                      onSubtotal: state.tipOnSubtotal,
                      onChanged: (v) => notifier.setTipOnSubtotal(v),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _SectionLabel('PEOPLE'),
                  _SettingsCard(children: [
                    _ToggleRow(
                      label: 'Remember recent names',
                      value: state.rememberNames,
                      onChanged: (v) => notifier.setRememberNames(v),
                    ),
                    const _CardDivider(),
                    _ActionRow(
                      label: 'Clear recent names',
                      color: AppColors.coralPink,
                      onTap: () => _clearRecentNames(context, ref),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _SectionLabel('APPEARANCE'),
                  _SettingsCard(children: [
                    _ThemeRow(
                      themeMode: state.themeMode,
                      onChanged: (mode) => notifier.setThemeMode(mode),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  if (!iapState.isPro) ...[
                    _SectionLabel('UPGRADE'),
                    _ProUpgradeCard(
                      isLoading: iapState.isPurchasing,
                      onTap: () => context.push(AppRoutes.proUnlock),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    _SectionLabel('UPGRADE'),
                    _SettingsCard(children: [
                      _NavRow(
                        label: '✓ SplitFair Pro',
                        trailing: 'Active',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],
                  _SectionLabel('SUPPORT'),
                  _SettingsCard(children: [
                    _NavRow(
                      label: 'Rate SplitFair',
                      onTap: () =>
                          _openUrl('https://apps.apple.com/app/id000000000'),
                    ),
                    const _CardDivider(),
                    _NavRow(
                      label: 'Share SplitFair',
                      onTap: _shareApp,
                    ),
                    const _CardDivider(),
                    _NavRow(
                      label: 'Privacy Policy',
                      onTap: () => _openUrl('https://najmulmyself.github.io/splitfair/privacy'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: _CoffeeBanner(
                isLoading: iapState.isPurchasing,
                onTap: iapState.isPurchasing
                    ? null
                    : () {
                        Haptics.heavyImpact();
                        iapNotifier.purchaseCoffee();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Split bills effortlessly with SplitFair!\nhttps://apps.apple.com/app/id000000000',
      ),
    );
  }

  Future<void> _showTipPicker(
    BuildContext context,
    String current,
    SettingsNotifier notifier,
  ) async {
    Haptics.impact();
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TipPickerSheet(current: current),
    );
    if (result != null) {
      notifier.setDefaultTipPercentage(result);
      Haptics.selection();
    }
  }

  Future<void> _clearRecentNames(BuildContext context, WidgetRef ref) async {
    Haptics.impact();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear Recent Names?'),
        content:
            const Text('This will remove all saved names from autocomplete.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(settingsRepositoryProvider).clearRecentNames();
      Haptics.selection();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SettingsAppBar extends StatelessWidget {
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
            'Settings',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.colors.textSecondary,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderDefault),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      color: context.colors.borderDefault,
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    this.trailing,
    required this.onTap,
  });

  final String label;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 16,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 16,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: (v) {
              Haptics.selection();
              onChanged(v);
            },
            activeTrackColor: AppColors.emeraldMint,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _TipOnRow extends StatelessWidget {
  const _TipOnRow({required this.onSubtotal, required this.onChanged});

  final bool onSubtotal;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Tip on',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          _SegmentedControl(
            options: const ['Subtotal', 'Total'],
            selectedIndex: onSubtotal ? 0 : 1,
            onChanged: (i) {
              Haptics.selection();
              onChanged(i == 0);
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.themeMode, required this.onChanged});

  final String themeMode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const modes = ['dark', 'light', 'system'];
    final selectedIndex = modes.indexOf(themeMode).clamp(0, 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Theme',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          _SegmentedControl(
            options: const ['Dark', 'Light', 'Sys'],
            selectedIndex: selectedIndex,
            onChanged: (i) {
              Haptics.selection();
              onChanged(modes[i]);
            },
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.colors.surface3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              height: double.infinity,
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primaryViolet : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CoffeeBanner extends StatelessWidget {
  const _CoffeeBanner({required this.isLoading, this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: context.colors.surface1,
          border: Border(
            top: BorderSide(color: context.colors.borderDefault),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9F43), Color(0xFFFF6B9D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Center(
                child: Text('\u2615', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buy me a coffee',
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'One-time \$0.99 \u2014 no pressure.',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 56,
                height: 32,
                child: Center(child: CupertinoActivityIndicator()),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primaryViolet,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '\$0.99',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TipPickerSheet extends StatelessWidget {
  const _TipPickerSheet({required this.current});
  final String current;

  static const _options = [
    '0',
    '5',
    '10',
    '12',
    '15',
    '18',
    '20',
    '22',
    '25',
    '30',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Default Tip',
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._options.map(
                      (pct) => _TipOption(
                        percentage: pct,
                        isSelected: pct == current,
                        onTap: () {
                          Haptics.selection();
                          Navigator.pop(context, pct);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipOption extends StatelessWidget {
  const _TipOption({
    required this.percentage,
    required this.isSelected,
    required this.onTap,
  });

  final String percentage;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primaryViolet
                    : context.colors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_rounded,
                  color: AppColors.primaryViolet, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Pro upgrade card ──────────────────────────────────────────────────────

class _ProUpgradeCard extends StatelessWidget {
  const _ProUpgradeCard({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1B8E), Color(0xFF7C5CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryViolet.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upgrade to Pro',
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'No ads · PDF export · Unlimited history',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryViolet),
                    )
                  : const Text(
                      '\$2.99',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryViolet,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
