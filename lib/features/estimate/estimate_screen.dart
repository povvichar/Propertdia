import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/module_hero_sliver.dart';
import 'data/valuation.dart';
import 'widgets/estimate_widgets.dart';

class EstimateScreen extends StatelessWidget {
  const EstimateScreen({super.key});

  /// How many recent valuations to preview on the hub before "See all".
  static const _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: valuationStore,
          builder: (context, _) {
            final all = [...valuationStore.items]
              ..sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
            final preview = all.take(_previewCount).toList();
            return CustomScrollView(
              slivers: [
                const ModuleHeroSliver(
              title: 'Estimate & Valuation',
              headline: 'Know your property’s value',
              subtitle:
                  'Free instant estimate · or a certified valuer’s report',
              icon: 'assets/icons/base/house.svg',
              iconSize: 168,
              iconTop: 22,
              iconRight: -28,
            ),
            ModuleHeroSheet(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _InstantCard(),
                  const SizedBox(height: 24),
                  const _SectionTitle('Professional valuation'),
                  const SizedBox(height: 4),
                  Text(
                    'Certified figure & signed PDF report by a licensed valuer.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _TypeCard(type: ValuationType.land),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _TypeCard(type: ValuationType.building),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const _SectionTitle('My valuations'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.iconTile,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${all.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (all.length > _previewCount)
                        _SeeAllLink(
                          onTap: () => context.push('/estimate/valuations'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (preview.isEmpty)
                    const _EmptyHub(
                      icon: 'assets/icons/base/scale.svg',
                      message:
                          'No valuations yet.\nRequest one above to get started.',
                    )
                  else
                    for (var i = 0; i < preview.length; i++) ...[
                      ValuationCard(valuation: preview[i]),
                      if (i != preview.length - 1) const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Free instant-estimate entry — the prominent top tier on the hub.
class _InstantCard extends StatelessWidget {
  const _InstantCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/estimate/instant'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.heroDiagonal,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Instant Estimate',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'See what your property is worth in seconds.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/base/arrowright.svg',
                  width: 15,
                  height: 15,
                  colorFilter:
                      const ColorFilter.mode(AppColors.navy, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type});

  final ValuationType type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/estimate/new', extra: EstimatePrefill(type: type)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        decoration: BoxDecoration(
          gradient: AppColors.heroDiagonal,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              type.asset,
              width: 30,
              height: 30,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(height: 14),
            Text(
              type.short,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Valuation',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: _GlassPricePill(price: usd(type.fee))),
                SvgPicture.asset(
                  'assets/icons/base/arrowright.svg',
                  width: 20,
                  height: 20,
                  colorFilter:
                      const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Liquid-glass price pill — translucent frosted fill over the card gradient.
class _GlassPricePill extends StatelessWidget {
  const _GlassPricePill({required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'From',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "See all" link beside the valuations header when there are more than the
/// hub preview shows.
class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Row(
        children: [
          Text(
            'See all',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          SizedBox(width: 2),
          Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.navy),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }
}

/// Placeholder shown when a hub list has no items yet.
class _EmptyHub extends StatelessWidget {
  const _EmptyHub({required this.icon, required this.message});

  final String icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                    AppColors.textSecondary.withValues(alpha: 0.6),
                    BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
