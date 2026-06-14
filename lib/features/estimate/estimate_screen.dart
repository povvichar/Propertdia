import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_icon_button.dart';
import 'data/valuation.dart';
import 'widgets/estimate_widgets.dart';

class EstimateScreen extends StatelessWidget {
  const EstimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TopBar(),
                      const SizedBox(height: 16),
                      const _IntroCard(),
                      const SizedBox(height: 24),
                      const _SectionTitle('Request a valuation'),
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
                              '${mockValuations.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (mockValuations.isEmpty)
                const SliverToBoxAdapter(
                  child: _EmptyHub(
                    icon: 'assets/icons/base/scale.svg',
                    message:
                        'No valuations yet.\nRequest one above to get started.',
                  ),
                )
              else
                SliverList.separated(
                  itemCount: mockValuations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.fromLTRB(
                        16, 0, 16, i == mockValuations.length - 1 ? 32 : 0),
                    child: _ValuationCard(valuation: mockValuations[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIconButton(
          asset: 'assets/icons/base/careleft.svg',
          onTap: () => context.pop(),
        ),
        const SizedBox(width: 14),
        const Text(
          'Estimate & Valuation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.navyDepth,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 24,
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
                const Text(
                  'Professional property valuation',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Certified valuers · comparable analysis · PDF report in 3–5 days',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/base/scale.svg',
                width: 28,
                height: 28,
                colorFilter:
                    const ColorFilter.mode(AppColors.gold, BlendMode.srcIn),
              ),
            ),
          ),
        ],
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
      onTap: () => context.push('/estimate/new', extra: type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: SvgPicture.asset(
                  type.asset,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                      AppColors.navyIcon, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              type.short,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Valuation',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'From ${usd(type.fee)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/base/arrowright.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
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

class _ValuationCard extends StatelessWidget {
  const _ValuationCard({required this.valuation});

  final Valuation valuation;

  @override
  Widget build(BuildContext context) {
    final v = valuation;
    return GestureDetector(
      onTap: () => context.push('/estimate/detail', extra: v),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      v.type.asset,
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                          AppColors.navyIcon, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${v.refNo} · ${shortDate(v.submittedDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: v.status, compact: true),
              ],
            ),
            if (v.hasValue) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Estimated value',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.95),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    usd(v.estimatedValue!),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
