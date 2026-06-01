import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/split_result.dart';
import '../calculator/providers/calculator_provider.dart';

/// Full-screen Share Results view.
class ShareSheet extends ConsumerStatefulWidget {
  const ShareSheet({super.key});

  @override
  ConsumerState<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<ShareSheet> {
  final _screenshotController = ScreenshotController();

  // ── Helpers ───────────────────────────────────────────────────

  Future<Uint8List?> _captureCard() async {
    try {
      return await _screenshotController.capture(pixelRatio: 3.0);
    } catch (_) {
      return null;
    }
  }

  String _buildTextSummary(
    List<SplitResult> results,
    Decimal grandTotal,
    String currencyCode,
    String sessionTitle,
    Decimal tipPct,
  ) {
    final buf = StringBuffer();
    buf.writeln('$sessionTitle — Split via SplitFair');
    buf.writeln('');
    for (final r in results) {
      buf.writeln(
          '${r.person.name}: $currencyCode ${r.total.toStringAsFixed(2)}');
    }
    buf.writeln('');
    buf.writeln(
        'Total incl. ${tipPct.toStringAsFixed(0)}% tip: $currencyCode ${grandTotal.toStringAsFixed(2)}');
    return buf.toString();
  }

  Future<void> _shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _shareImage(String text) async {
    final bytes = await _captureCard();
    if (bytes == null) {
      await _shareText(text);
      return;
    }
    final xFile =
        XFile.fromData(bytes, mimeType: 'image/png', name: 'splitfair.png');
    await SharePlus.instance.share(ShareParams(files: [xFile], text: text));
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard',
            style: TextStyle(color: Colors.white)),
        backgroundColor: context.colors.surface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openWhatsApp(String text) async {
    final encoded = Uri.encodeComponent(text);
    final uri = Uri.parse('whatsapp://send?text=$encoded');
    if (!await launchUrl(uri)) {
      final webUri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openVenmo(String note) async {
    final uri = Uri.parse(
        'venmo://paycharge?txn=pay&note=${Uri.encodeComponent(note)}');
    if (!await launchUrl(uri)) {
      await launchUrl(Uri.parse('https://venmo.com/'),
          mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openCashApp(String note) async {
    final uri = Uri.parse('cashme://cash.app/launch?');
    if (!await launchUrl(uri)) {
      await launchUrl(Uri.parse('https://cash.app/'),
          mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPayPal(String note) async {
    await launchUrl(Uri.parse('https://paypal.me/'),
        mode: LaunchMode.externalApplication);
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorNotifierProvider);
    final notifier = ref.read(calculatorNotifierProvider.notifier);
    final results = notifier.results;
    final grandTotal = notifier.grandTotal;
    final tip = notifier.computedTip;
    final tipPct = calcState.tipPercentage;
    final currencyCode = calcState.currencyCode;
    final sessionTitle = calcState.sessionLabel?.isNotEmpty == true
        ? calcState.sessionLabel!
        : 'Split Session';
    final today = DateFormat('MMM d').format(DateTime.now()).toUpperCase();
    final textSummary = _buildTextSummary(
        results, grandTotal, currencyCode, sessionTitle, tipPct);

    return Scaffold(
      backgroundColor: context.colors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: context.colors.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Share Results',
                      style: TextStyle(
                        fontFamily: '.SF Pro Display',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result card (capturable)
                    Screenshot(
                      controller: _screenshotController,
                      child: _ResultCard(
                        results: results,
                        grandTotal: grandTotal,
                        tip: tip,
                        tipPct: tipPct,
                        currencyCode: currencyCode,
                        sessionTitle: sessionTitle,
                        dateLabel: today,
                      ),
                    ).animate().fade(duration: 350.ms).slideY(
                        begin: -0.04,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOut),

                    const SizedBox(height: 28),

                    // ── SEND VIA ────────────────────────────
                    _SectionLabel(label: 'SEND VIA'),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SendButton(
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          child: const Text('W',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: '.SF Pro Display')),
                          onTap: () {
                            Haptics.impact();
                            _openWhatsApp(textSummary);
                          },
                        ),
                        _SendButton(
                          label: 'iMessage',
                          color: const Color(0xFF34C759),
                          child: const Icon(Icons.message_rounded,
                              color: Colors.white, size: 22),
                          onTap: () {
                            Haptics.impact();
                            _shareText(textSummary);
                          },
                        ),
                        _SendButton(
                          label: 'Copy',
                          color: context.colors.surface2,
                          child: Icon(Icons.copy_rounded,
                              color: context.colors.textSecondary, size: 22),
                          onTap: () {
                            Haptics.selection();
                            _copyToClipboard(textSummary);
                          },
                        ),
                        _SendButton(
                          label: 'Save',
                          color: AppColors.warmAmber,
                          child: const Icon(Icons.download_rounded,
                              color: Colors.white, size: 22),
                          onTap: () {
                            Haptics.impact();
                            _shareImage(textSummary);
                          },
                        ),
                      ],
                    ).animate().fade(duration: 300.ms, delay: 120.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 350.ms,
                        delay: 120.ms,
                        curve: Curves.easeOut),

                    const SizedBox(height: 24),

                    // ── REQUEST PAYMENT ─────────────────────
                    Row(
                      children: [
                        _SectionLabel(label: 'REQUEST PAYMENT'),
                        const Spacer(),
                        // Person avatar stack
                        if (results.isNotEmpty) _AvatarStack(results: results),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _PaymentButtons(
                      onVenmo: () {
                        Haptics.impact();
                        _openVenmo(sessionTitle);
                      },
                      onCashApp: () {
                        Haptics.impact();
                        _openCashApp(sessionTitle);
                      },
                      onPayPal: () {
                        Haptics.impact();
                        _openPayPal(sessionTitle);
                      },
                    ).animate().fade(duration: 300.ms, delay: 200.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 350.ms,
                        delay: 200.ms,
                        curve: Curves.easeOut),
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

// ── Result Card ───────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.results,
    required this.grandTotal,
    required this.tip,
    required this.tipPct,
    required this.currencyCode,
    required this.sessionTitle,
    required this.dateLabel,
  });

  final List<SplitResult> results;
  final Decimal grandTotal;
  final Decimal tip;
  final Decimal tipPct;
  final String currencyCode;
  final String sessionTitle;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2D1B8E),
            Color(0xFF5C3DC8),
            Color(0xFFAA4B9E),
            Color(0xFFFF6B9D)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5CFF).withOpacity(0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateLabel,
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white60,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                // SplitFair badge
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/icons/icon.png',
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'SplitFair',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Session title
            Text(
              sessionTitle,
              style: const TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 20),

            // Person rows
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: results.asMap().entries.map((e) {
                  final i = e.key;
                  final r = e.value;
                  final isLast = i == results.length - 1;
                  final gradients = AppColors.personGradients;
                  final g = gradients[r.person.colorIndex % gradients.length];
                  final initial = r.person.name.isNotEmpty
                      ? r.person.name[0].toUpperCase()
                      : '?';
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [g[0], g[1]],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(initial,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: '.SF Pro Display')),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r.person.name,
                                style: const TextStyle(
                                  fontFamily: '.SF Pro Text',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '$currencyCode ${r.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: '.SF Pro Display',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Container(
                            height: 1, color: Colors.white.withOpacity(0.1)),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            // Total row
            Row(
              children: [
                Text(
                  'Total · incl. ${tipPct.toStringAsFixed(0)}% tip',
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Text(
                  '$currencyCode ${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.label,
    required this.color,
    required this.child,
    required this.onTap,
  });
  final String label;
  final Color color;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: child),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.results});
  final List<SplitResult> results;

  @override
  Widget build(BuildContext context) {
    const size = 22.0;
    const overlap = 8.0;
    final count = results.length.clamp(0, 4);
    final width = size + (count - 1) * (size - overlap);
    final gradients = AppColors.personGradients;

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: List.generate(count, (i) {
          final r = results[i];
          final g = gradients[r.person.colorIndex % gradients.length];
          final initial =
              r.person.name.isNotEmpty ? r.person.name[0].toUpperCase() : '?';
          return Positioned(
            left: i * (size - overlap),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [g[0], g[1]],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: context.colors.bgBase, width: 1.5),
              ),
              child: Center(
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PaymentButtons extends StatelessWidget {
  const _PaymentButtons({
    required this.onVenmo,
    required this.onCashApp,
    required this.onPayPal,
  });

  final VoidCallback onVenmo;
  final VoidCallback onCashApp;
  final VoidCallback onPayPal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PayButton(label: 'Venmo', onTap: onVenmo),
        const SizedBox(width: 10),
        _PayButton(label: 'Cash App', onTap: onCashApp),
        const SizedBox(width: 10),
        _PayButton(label: 'PayPal', onTap: onPayPal),
        const SizedBox(width: 10),
        _PayButton(label: 'bKash', onTap: () {}),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: context.colors.surface1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderDefault),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
