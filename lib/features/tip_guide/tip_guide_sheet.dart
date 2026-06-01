import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/sources/tip_guide_data_source.dart';

/// Bottom sheet showing country-specific tipping customs.
/// Tapping a country applies its typical tip mid-point to the calculator.
class TipGuideSheet extends StatefulWidget {
  const TipGuideSheet({super.key});

  @override
  State<TipGuideSheet> createState() => _TipGuideSheetState();
}

class _TipGuideSheetState extends State<TipGuideSheet> {
  List<CountryTipGuide> _all = [];
  List<CountryTipGuide> _filtered = [];
  final _search = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_onSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await TipGuideDataSource.instance.loadAll();
    if (!mounted) return;
    setState(() {
      _all = data;
      _filtered = data;
      _loading = false;
    });
  }

  void _onSearch() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
              .where((c) => c.country.toLowerCase().contains(q))
              .toList();
    });
  }

  /// Parse "15–20%" or "0%" → return the mid-point as integer string.
  String _midPoint(String typical) {
    final clean = typical.replaceAll('%', '').trim();
    if (clean.contains('–')) {
      final parts = clean.split('–');
      final lo = double.tryParse(parts[0].trim()) ?? 0;
      final hi = double.tryParse(parts[1].trim()) ?? lo;
      return ((lo + hi) / 2).round().toString();
    }
    return (double.tryParse(clean) ?? 0).round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.borderDefault,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text(
                  '🌍  Tipping by Country',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded,
                      color: context.colors.textSecondary, size: 20),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 15,
                  color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search country…',
                hintStyle:
                    TextStyle(color: context.colors.textTertiary, fontSize: 15),
                prefixIcon:
                    Icon(Icons.search_rounded, color: context.colors.textTertiary),
                filled: true,
                fillColor: context.colors.surface2,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Flexible(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No countries found.',
                          style: TextStyle(color: context.colors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => Container(
                          height: 1,
                          color: context.colors.borderDefault,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                        itemBuilder: (context, i) {
                          final c = _filtered[i];
                          final mid = _midPoint(c.typical);
                          return _CountryRow(
                            guide: c,
                            onTap: () => Navigator.pop(context, mid),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Country row ───────────────────────────────────────────────────────────

class _CountryRow extends StatelessWidget {
  const _CountryRow({required this.guide, required this.onTap});
  final CountryTipGuide guide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Text(guide.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.country,
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (guide.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      guide.note!,
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 12,
                        color: context.colors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryViolet.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primaryViolet.withOpacity(0.3)),
              ),
              child: Text(
                guide.typical,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 13,
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
