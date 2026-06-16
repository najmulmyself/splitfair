import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/split_result.dart';
import '../../data/sources/tip_guide_data_source.dart';
import '../../shared/widgets/admob/ad_config.dart';
import '../../shared/widgets/admob/banner_ad_widget.dart';
import '../../shared/widgets/admob/interstitial_ad_service.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../calculator/providers/calculator_provider.dart';
import '../settings/settings_provider.dart';

/// Full-screen Share Results view.
class ShareSheet extends ConsumerStatefulWidget {
  const ShareSheet({super.key});

  @override
  ConsumerState<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<ShareSheet> {
  final _screenshotController = ScreenshotController();
  final _shareRowKey = GlobalKey();

  bool get _adsEnabled {
    final repo = ref.read(settingsRepositoryProvider);
    final isPro = ref.read(settingsNotifierProvider).isPro;
    return !isPro && repo.sessionCount >= AdConfig.adFreeSessionThreshold;
  }

  bool get _isPro => ref.read(settingsNotifierProvider).isPro;

  Future<void> _triggerInterstitial() async {
    if (!_adsEnabled) return;
    await Future.delayed(const Duration(milliseconds: 600));
    await InterstitialAdService.instance.show();
  }

  // Returns a Rect for iPad share-sheet popover anchoring.
  Rect get _sharePopoverOrigin {
    final box =
        _shareRowKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    final pos = box.localToGlobal(Offset.zero);
    return pos & box.size;
  }

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
    Decimal tipPct, {
    bool useIndividualTips = false,
    Map<String, int> perPersonTipBps = const {},
    bool useFlexSplit = false,
  }) {
    final buf = StringBuffer();
    buf.writeln('$sessionTitle — Split via DivvyBill');
    buf.writeln('');
    for (final r in results) {
      if (useIndividualTips && perPersonTipBps.containsKey(r.person.id)) {
        final bps = perPersonTipBps[r.person.id]!;
        final pct = bps ~/ 100;
        final tipSuffix = pct == 0 ? ' (no tip)' : ' (incl. $pct% tip)';
        buf.writeln(
            '${r.person.name}: $currencyCode ${r.total.toStringAsFixed(2)}$tipSuffix');
      } else {
        buf.writeln(
            '${r.person.name}: $currencyCode ${r.total.toStringAsFixed(2)}');
      }
    }
    buf.writeln('');
    buf.writeln(
        '${_totalLabel(tipPct, useIndividualTips: useIndividualTips, perPersonTipBps: perPersonTipBps, useFlexSplit: useFlexSplit)}: $currencyCode ${grandTotal.toStringAsFixed(2)}');
    return buf.toString();
  }


  Future<void> _shareText(String text) async {
    await Share.share(text, sharePositionOrigin: _sharePopoverOrigin);
    _triggerInterstitial();
  }

  Future<void> _shareImage(String text) async {
    final bytes = await _captureCard();
    if (bytes == null) {
      await _shareText(text);
      return;
    }
    final xFile =
        XFile.fromData(bytes, mimeType: 'image/png', name: 'divvybill.png');
    await Share.shareXFiles([xFile],
        text: text, sharePositionOrigin: _sharePopoverOrigin);
    _triggerInterstitial();
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

  Future<void> _openBkash(String summary) async {
    final uri = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent(summary)}');
    if (!await launchUrl(uri)) {
      await _copyToClipboard(summary);
    }
  }

  Future<void> _sharePdf(String text) async {
    final bytes = await _captureCard();
    if (bytes == null) {
      await _shareText(text);
      return;
    }
    final doc = pw.Document();
    final image = pw.MemoryImage(bytes);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Center(child: pw.Image(image)),
      ),
    );
    final pdfBytes = await doc.save();
    final xFile = XFile.fromData(
      Uint8List.fromList(pdfBytes),
      mimeType: 'application/pdf',
      name: 'divvybill_result.pdf',
    );
    await Share.shareXFiles([xFile],
        text: text, sharePositionOrigin: _sharePopoverOrigin);
    _triggerInterstitial();
  }

  Future<void> _openZelle() async {
    final uri = Uri.parse('zelle://');
    if (!await launchUrl(uri)) {
      await launchUrl(Uri.parse('https://zellepay.com'),
          mode: LaunchMode.externalApplication);
    }
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
    final useIndividualTips = calcState.useIndividualTips;
    final perPersonTipBps = calcState.perPersonTipBps;
    final useFlexSplit = calcState.useFlexSplit;
    final sessionTitle = calcState.sessionLabel?.isNotEmpty == true
        ? calcState.sessionLabel!
        : 'Split Session';
    final today = DateFormat('MMM d').format(DateTime.now()).toUpperCase();
    final textSummary = _buildTextSummary(
      results, grandTotal, currencyCode, sessionTitle, tipPct,
      useIndividualTips: useIndividualTips,
      perPersonTipBps: perPersonTipBps,
      useFlexSplit: useFlexSplit,
    );

    final adsEnabled = _adsEnabled;

    return Scaffold(
      backgroundColor: context.colors.bgBase,
      bottomNavigationBar: adsEnabled
          ? const BannerAdWidget()
          : null,
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
                        useIndividualTips: useIndividualTips,
                        perPersonTipBps: perPersonTipBps,
                        useFlexSplit: useFlexSplit,
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
                      key: _shareRowKey,
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
                            _triggerInterstitial();
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
                        _SendButton(
                          label: 'PDF',
                          color: _isPro
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFF9E9E9E),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Text('PDF',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: '.SF Pro Display')),
                              if (!_isPro)
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(Icons.lock_rounded,
                                      color: Colors.white, size: 10),
                                ),
                            ],
                          ),
                          onTap: () {
                            Haptics.impact();
                            if (_isPro) {
                              _sharePdf(textSummary);
                            } else {
                              context.push(AppRoutes.proUnlock);
                            }
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
                      onBkash: () {
                        Haptics.impact();
                        _openBkash(textSummary);
                      },
                      onZelle: () {
                        Haptics.impact();
                        _openZelle();
                      },
                    ).animate().fade(duration: 300.ms, delay: 200.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 350.ms,
                        delay: 200.ms,
                        curve: Curves.easeOut),

                    if (results.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      // ── WHO COVERED? ─────────────────────────
                      _SectionLabel(label: 'WHO COVERED THE BILL?'),
                      const SizedBox(height: 12),
                      _WhoPayedRow(
                        results: results,
                        onSelect: (name) {
                          ref
                              .read(settingsRepositoryProvider)
                              .setLastPayer(name);
                          Haptics.selection();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name covered — noted for next time!',
                                  style:
                                      const TextStyle(color: Colors.white)),
                              backgroundColor:
                                  context.colors.surface2,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ).animate().fade(duration: 300.ms, delay: 280.ms),
                    ],
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

// ── Share helpers ─────────────────────────────────────────────────────────

String _totalLabel(
  Decimal tipPct, {
  bool useIndividualTips = false,
  Map<String, int> perPersonTipBps = const {},
  bool useFlexSplit = false,
}) {
  if (useFlexSplit) return 'Total · customized split';
  if (useIndividualTips && perPersonTipBps.isNotEmpty) {
    final uniqueBps = perPersonTipBps.values.toSet();
    if (uniqueBps.length == 1) {
      final pct = uniqueBps.first ~/ 100;
      return pct == 0 ? 'Total · no tip' : 'Total · incl. $pct% tip';
    }
    return 'Total · incl. tip';
  }
  if (tipPct == Decimal.zero) return 'Total · no tip';
  return 'Total · incl. ${tipPct.toStringAsFixed(0)}% tip';
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
    this.useIndividualTips = false,
    this.perPersonTipBps = const {},
    this.useFlexSplit = false,
  });

  final List<SplitResult> results;
  final Decimal grandTotal;
  final Decimal tip;
  final Decimal tipPct;
  final String currencyCode;
  final String sessionTitle;
  final String dateLabel;
  final bool useIndividualTips;
  final Map<String, int> perPersonTipBps;
  final bool useFlexSplit;

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
                // DivvyBill badge
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
                      'DivvyBill',
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$currencyCode ${r.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: '.SF Pro Display',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                if (useIndividualTips &&
                                    perPersonTipBps.containsKey(r.person.id))
                                  Builder(builder: (_) {
                                    final bps =
                                        perPersonTipBps[r.person.id]!;
                                    final pct = bps ~/ 100;
                                    return Text(
                                      pct == 0 ? 'no tip' : '$pct% tip',
                                      style: const TextStyle(
                                        fontFamily: '.SF Pro Text',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white54,
                                      ),
                                    );
                                  }),
                              ],
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
                  _totalLabel(
                    tipPct,
                    useIndividualTips: useIndividualTips,
                    perPersonTipBps: perPersonTipBps,
                    useFlexSplit: useFlexSplit,
                  ),
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

            // Tipping etiquette badge
            _TipEtiquetteBadge(currencyCode: currencyCode),
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
    required this.onBkash,
    required this.onZelle,
  });

  final VoidCallback onVenmo;
  final VoidCallback onCashApp;
  final VoidCallback onPayPal;
  final VoidCallback onBkash;
  final VoidCallback onZelle;

  @override
  Widget build(BuildContext context) {
    // Scrollable so adding more apps never overflows
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PayButton(label: 'Venmo', onTap: onVenmo),
          const SizedBox(width: 10),
          _PayButton(label: 'Cash App', onTap: onCashApp),
          const SizedBox(width: 10),
          _PayButton(label: 'PayPal', onTap: onPayPal),
          const SizedBox(width: 10),
          _PayButton(label: 'Zelle', onTap: onZelle),
          const SizedBox(width: 10),
          _PayButton(label: 'bKash', onTap: onBkash),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
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
    );
  }
}

// ── Who covered the bill row ──────────────────────────────────────────────

class _WhoPayedRow extends StatefulWidget {
  const _WhoPayedRow({required this.results, required this.onSelect});
  final List<SplitResult> results;
  final ValueChanged<String> onSelect;

  @override
  State<_WhoPayedRow> createState() => _WhoPayedRowState();
}

class _WhoPayedRowState extends State<_WhoPayedRow> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final gradients = AppColors.personGradients;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.results.map((r) {
        final g = gradients[r.person.colorIndex % gradients.length];
        final isSelected = _selected == r.person.name;
        return GestureDetector(
          onTap: () {
            setState(() => _selected = r.person.name);
            widget.onSelect(r.person.name);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: [g[0], g[1]])
                  : null,
              color: isSelected ? null : context.colors.surface1,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : context.colors.borderDefault,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.check_rounded,
                        color: Colors.white, size: 14),
                  ),
                Text(
                  r.person.name,
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tipping etiquette badge ───────────────────────────────────────────────

/// Maps ISO currency code → country name in TipGuideDataSource.
const _kCurrencyCountry = {
  'USD': 'United States',
  'GBP': 'United Kingdom',
  'CAD': 'Canada',
  'AUD': 'Australia',
  'JPY': 'Japan',
  'EUR': 'Germany',
  'CNY': 'China',
  'INR': 'India',
  'BDT': 'Bangladesh',
  'SGD': 'Singapore',
  'AED': 'UAE',
  'MXN': 'Mexico',
  'BRL': 'Brazil',
  'KRW': 'South Korea',
  'THB': 'Thailand',
  'TRY': 'Turkey',
  'CHF': 'Switzerland',
};

class _TipEtiquetteBadge extends StatefulWidget {
  const _TipEtiquetteBadge({required this.currencyCode});
  final String currencyCode;

  @override
  State<_TipEtiquetteBadge> createState() => _TipEtiquetteBadgeState();
}

class _TipEtiquetteBadgeState extends State<_TipEtiquetteBadge> {
  CountryTipGuide? _guide;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final countryName = _kCurrencyCountry[widget.currencyCode];
    if (countryName == null) return;
    final all = await TipGuideDataSource.instance.loadAll();
    final match = all.where((c) => c.country == countryName).toList();
    if (match.isNotEmpty && mounted) {
      setState(() => _guide = match.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_guide == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_guide!.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_guide!.country} · ${_guide!.typical}',
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (_guide!.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _guide!.note!,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 11,
                        color: Colors.white54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
