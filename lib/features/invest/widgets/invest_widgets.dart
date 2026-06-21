import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_icon_button.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../favorites/data/favorites.dart';
import '../data/invest.dart';

/// Navy/white pill segmented control used at the top of the Invest hub.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 16,
      opacity: 0.66,
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 38,
        child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: i == index ? Colors.white : AppColors.textSecondary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Heart toggle that saves a project to favorites. Rebuilds on store changes.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.project,
    this.onDark = false,
    this.size = 34,
  });

  final InvestProject project;
  final bool onDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: favoritesStore,
      builder: (context, _) {
        final fav = favoritesStore.hasProject(project.id);
        return GestureDetector(
          onTap: () => favoritesStore.toggleProject(project),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: onDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                fav
                    ? 'assets/icons/base/heart_fill.svg'
                    : 'assets/icons/base/heart.svg',
                width: size * 0.5,
                height: size * 0.5,
                colorFilter: ColorFilter.mode(
                  fav
                      ? AppColors.gold
                      : (onDark ? Colors.white : AppColors.textSecondary),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact opportunity row — thumbnail + key facts + favorite, used on the
/// "all opportunities" list.
class ProjectListItem extends StatelessWidget {
  const ProjectListItem({super.key, required this.project, required this.onTap});

  final InvestProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = project;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                p.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.surfaceMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${p.targetRoi.toStringAsFixed(0)}% ROI',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Min ${usd(p.minInvest)} · ${(p.fundedPct * 100).round()}% funded · ${p.termMonths} mo',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            FavoriteButton(project: p, size: 30),
          ],
        ),
      ),
    );
  }
}

/// A single project opportunity card.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});

  final InvestProject project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final locked = !investStore.canInvestIn(p);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 8,
                  child: Image.network(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.surfaceMuted),
                  ),
                ),
                if (locked)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.navy.withValues(alpha: 0.45),
                    ),
                  ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _Tag(label: p.type.label, color: p.type.color),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _Tag(
                    label: '${p.targetRoi.toStringAsFixed(0)}% ROI',
                    color: AppColors.gold,
                    dark: true,
                  ),
                ),
                if (locked)
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: _Tag(
                      label: '🔒 ${p.minTier.label}+ early access',
                      color: AppColors.platinum,
                      dark: true,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FavoriteButton(project: p),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/base/mappin.svg',
                        width: 13,
                        height: 13,
                        colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FundingBar(pct: p.fundedPct),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${(p.fundedPct * 100).round()}% funded',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Min ${usd(p.minInvest)} · ${p.termMonths} mo',
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
          ],
        ),
      ),
    );
  }
}

class FundingBar extends StatelessWidget {
  const FundingBar({super.key, required this.pct});

  final double pct;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: pct,
        minHeight: 7,
        backgroundColor: AppColors.iconTile,
        valueColor: const AlwaysStoppedAnimation(AppColors.gold),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, this.dark = false});

  final String label;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: dark ? AppColors.navy : Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// Compact key/value stat used in stat rows.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Standard top bar reused across the invest screens.
class InvestTopBar extends StatelessWidget {
  const InvestTopBar({super.key, required this.title, this.trailing, this.onBack});

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          GlassIconButton(
            asset: 'assets/icons/base/careleft.svg',
            onTap: onBack!,
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

