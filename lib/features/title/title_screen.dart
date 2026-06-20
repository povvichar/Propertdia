import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/module_hero_sliver.dart';
import 'data/title_service.dart';
import 'widgets/title_widgets.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  /// How many recent applications to preview on the hub before "See all".
  static const _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: titleStore,
          builder: (context, _) {
            final apps = [...titleStore.items]
              ..sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
            final preview = apps.take(_previewCount).toList();
            return CustomScrollView(
          slivers: [
            const ModuleHeroSliver(
              title: 'Title Services',
              headline: 'Verify & Transfer Property Titles',
              subtitle:
                  'Cadastral registry checks · secure uploads · status tracking',
              icon: 'assets/icons/base/certificate.svg',
              iconSize: 150,
              iconTop: 10,
              iconRight: -18,
            ),
            ModuleHeroSheet(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _EligibilityHubCard(),
                  const SizedBox(height: 24),
                  const _SectionTitle('Choose a service'),
                  const SizedBox(height: 12),
                  for (final t in TitleServiceType.values) ...[
                    _ServiceCard(type: t),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const _SectionTitle('My applications'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.iconTile,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${apps.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (apps.length > _previewCount)
                        _SeeAllLink(
                          onTap: () => context.push('/profile/applications'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (preview.isEmpty)
                    const _EmptyHub(
                      icon: 'assets/icons/base/locked.svg',
                      message:
                          'No applications yet.\nStart a service above to get going.',
                    )
                  else
                    for (var i = 0; i < preview.length; i++) ...[
                      ApplicationCard(app: preview[i]),
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

/// "See all" link shown beside the applications header when there are more
/// applications than the hub preview shows.
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

/// Free ownership-eligibility entry — the prominent top tier on the hub.
class _EligibilityHubCard extends StatelessWidget {
  const _EligibilityHubCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/title/eligibility'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.heroDiagonal,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                        'Check Ownership Eligibility',
                        style: TextStyle(
                          fontSize: 15,
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
                    'Foreign-ownership rules · land vs. strata · in seconds.',
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.type});

  final TitleServiceType type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/title/new', extra: type),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(13),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'From ${usd(type.fee)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        '  ·  ~${type.workingDays} working days',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              'assets/icons/base/careright.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary, BlendMode.srcIn),
            ),
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
