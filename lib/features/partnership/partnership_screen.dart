import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/module_hero_sliver.dart';
import 'data/partnership.dart';

class PartnershipScreen extends StatelessWidget {
  const PartnershipScreen({super.key, this.showBack = true});

  /// Hide the header back button when shown as a top-level nav tab.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final local = partnersByScope(PartnerScope.local);
    final global = partnersByScope(PartnerScope.global);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            ModuleHeroSliver(
              title: 'Partnership',
              headline: 'Trusted Partner ecosystem',
              subtitle:
                  'Building a smarter, more connected property ecosystem in Cambodia.',
              icon: 'assets/icons/base/Partnership.svg',
              iconSize: 176,
              iconTop: 10,
              iconRight: -20,
              showBack: showBack,
            ),
            ModuleHeroSheet(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GroupHeader(
                    title: 'Local Partners',
                    count: local.length,
                    icon: 'assets/icons/base/mappin.svg',
                  ),
                  const SizedBox(height: 14),
                  _PartnerGrid(partners: local),
                  const SizedBox(height: 26),
                  _GroupHeader(
                    title: 'Global Partners',
                    count: global.length,
                    icon: 'assets/icons/base/globe.svg',
                  ),
                  const SizedBox(height: 14),
                  _PartnerGrid(partners: global),
                  const SizedBox(height: 26),
                  const _BecomePartnerCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 18,
          height: 18,
          colorFilter:
              const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.iconTile,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}

class _PartnerGrid extends StatelessWidget {
  const _PartnerGrid({required this.partners});

  final List<Partner> partners;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 116,
      ),
      itemCount: partners.length,
      itemBuilder: (context, i) => _PartnerCard(partner: partners[i]),
    );
  }
}

class _PartnerCard extends StatefulWidget {
  const _PartnerCard({required this.partner});

  final Partner partner;

  @override
  State<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<_PartnerCard> {
  bool _pressed = false;

  void _showSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PartnerSheet(partner: widget.partner),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.partner;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _showSheet,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PartnerLogo(partner: p, size: 46),
              const Spacer(),
              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                p.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders a real logo (SVG or PNG) on a clean tile, or a branded monogram
/// fallback when no logo asset is supplied.
class PartnerLogo extends StatelessWidget {
  const PartnerLogo({super.key, required this.partner, this.size = 46});

  final Partner partner;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = partner.logoAsset;
    if (asset != null) {
      final isSvg = asset.toLowerCase().endsWith('.svg');
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // Raster logos often carry their own background, so sit them on
          // white for crispness; SVG marks keep the muted tile.
          color: isSvg ? AppColors.surfaceMuted : Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: isSvg
            ? SvgPicture.asset(asset, fit: BoxFit.contain)
            : Image.asset(asset, fit: BoxFit.contain),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: partner.brandColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        partner.monogram,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: partner.brandColor,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _PartnerSheet extends StatelessWidget {
  const _PartnerSheet({required this.partner});

  final Partner partner;

  @override
  Widget build(BuildContext context) {
    final p = partner;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  PartnerLogo(partner: p, size: 58),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goldSoft,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            p.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                p.tagline,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.verified_rounded, size: 18, color: AppColors.gold),
                  SizedBox(width: 6),
                  Text(
                    'Verified PROPERTDIA partner',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BecomePartnerCard extends StatelessWidget {
  const _BecomePartnerCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.navy,
              content: Text('Partnership enquiry sent via Telegram'),
            ),
          );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/base/telegram.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                      AppColors.goldDark, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Become a partner',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'List your bank, agency or project with us',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
