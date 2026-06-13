import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_icon_button.dart';
import 'data/force_sale.dart';
import 'widgets/force_sale_card.dart';
import 'widgets/force_sale_filter_sheet.dart';

class ForceSaleScreen extends StatefulWidget {
  const ForceSaleScreen({super.key});

  @override
  State<ForceSaleScreen> createState() => _ForceSaleScreenState();
}

class _ForceSaleScreenState extends State<ForceSaleScreen> {
  SaleType? _quickType;
  ForceSaleFilter _adv = const ForceSaleFilter();
  bool _savedOnly = false;

  List<ForceSaleProperty> get _filtered => mockForceSale
      .where((p) =>
          (_quickType == null || p.saleType == _quickType) &&
          _adv.matches(p) &&
          (!_savedOnly || savedForceSale.contains(p.id)))
      .toList();

  Future<void> _openFilters() async {
    final result = await showForceSaleFilter(context,
        current: _adv, all: mockForceSale);
    if (result != null) setState(() => _adv = result);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        content: Text(msg),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: savedForceSale,
            builder: (context, _) {
              final list = _filtered;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TopBar(
                            savedCount: savedForceSale.count,
                            savedOnly: _savedOnly,
                            onToggleSaved: () =>
                                setState(() => _savedOnly = !_savedOnly),
                          ),
                          const SizedBox(height: 16),
                          _EmergencyCard(onContact: () =>
                              _toast('Connecting to 24/7 distressed-sale hotline…')),
                          const SizedBox(height: 16),
                          _SearchFilterRow(
                            activeCount: _adv.activeCount,
                            onFilters: _openFilters,
                          ),
                          const SizedBox(height: 12),
                          _TypeChips(
                            selected: _quickType,
                            onSelect: (t) => setState(() => _quickType = t),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _savedOnly
                                ? '${list.length} saved'
                                : '${list.length} opportunities',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  if (list.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyState())
                  else
                    SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.fromLTRB(
                            16, 0, 16, i == list.length - 1 ? 32 : 0),
                        child: ForceSaleCard(
                          property: list[i],
                          saved: savedForceSale.contains(list[i].id),
                          onSave: () => savedForceSale.toggle(list[i].id),
                          onTap: () =>
                              context.push('/force-sale/detail', extra: list[i]),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.savedCount,
    required this.savedOnly,
    required this.onToggleSaved,
  });

  final int savedCount;
  final bool savedOnly;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIconButton(
          asset: 'assets/icons/base/caretright.svg',
          onTap: () => context.pop(),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Force Sale',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        GestureDetector(
          onTap: onToggleSaved,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: savedOnly ? AppColors.navy : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Icon(
                  savedOnly
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 18,
                  color: savedOnly ? AppColors.gold : AppColors.navy,
                ),
                const SizedBox(width: 6),
                Text(
                  '$savedCount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: savedOnly ? Colors.white : AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              'assets/icons/base/alert.svg',
              width: 22,
              height: 22,
              colorFilter:
                  const ColorFilter.mode(AppColors.danger, BlendMode.srcIn),
              fit: BoxFit.none,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency support',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '24/7 hotline for time-sensitive deals',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onContact,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/base/phone.svg',
                  width: 18,
                  height: 18,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchFilterRow extends StatelessWidget {
  const _SearchFilterRow({required this.activeCount, required this.onFilters});

  final int activeCount;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/base/search.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                      AppColors.textSecondary, BlendMode.srcIn),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Search distressed properties',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onFilters,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/icons/base/slidershorizontal.svg',
                    width: 20,
                    height: 20,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                if (activeCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.selected, required this.onSelect});

  final SaleType? selected;
  final ValueChanged<SaleType?> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <(SaleType?, String)>[
      (null, 'All'),
      for (final t in SaleType.values) (t, t.label),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (type, label) = items[i];
          final isSel = type == selected;
          return GestureDetector(
            onTap: () => onSelect(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSel ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSel ? Colors.white : AppColors.navy,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text(
            'No matching opportunities',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
