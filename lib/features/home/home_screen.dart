import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/models/property.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/utils/l10n_ext.dart';
import '../favorites/favorites_view.dart';
import '../media/media_view.dart';
import '../partnership/partnership_screen.dart';
import '../profile/profile_view.dart';
import 'widgets/home_header.dart';
import 'widgets/property_card.dart';
import 'widgets/service_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: tab,
        children: const [
          _HomeBody(),
          FavoritesView(),
          MediaView(),
          PartnershipScreen(showBack: false),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: _GlassNav(
        current: tab,
        onChanged: (i) => ref.read(homeTabProvider.notifier).state = i,
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroCarousel(),
                const SizedBox(height: 20),
                const ServiceGrid(),
                const SizedBox(height: 20),
                _SectionTitle(title: context.l10n.homeBestPrice),
                const SizedBox(height: 12),
                SizedBox(
                  height: 218,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mockBestPrice.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) =>
                        PropertyCard(property: mockBestPrice[i], width: 220),
                  ),
                ),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  const _HeroCarousel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: const SizedBox(
        height: 148,
        width: double.infinity,
        child: Image(
          image: AssetImage('assets/images/banner.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.asset, this.label);

  final String asset;
  final String label;
}

List<_NavItem> _navItemsFor(AppLocalizations l) => [
      _NavItem('assets/icons/base/home.svg', l.navHome),
      _NavItem('assets/icons/base/bookmark.svg', l.navFavorite),
      _NavItem('assets/icons/base/clapperboard.svg', l.navMedia),
      _NavItem('assets/icons/base/Partnership.svg', l.navPartnership),
      _NavItem('assets/icons/base/profile.svg', l.navProfile),
    ];

class _GlassNav extends StatelessWidget {
  const _GlassNav({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navItems = _navItemsFor(context.l10n);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            border: Border(
              top: BorderSide(
                color: AppColors.navy.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.only(top: 12, bottom: bottomInset > 0 ? bottomInset : 8),
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                for (var i = 0; i < navItems.length; i++)
                  Expanded(
                    child: _GlassNavItem(
                      item: navItems[i],
                      active: i == current,
                      onTap: () => onChanged(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.navy : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              item.asset,
              width: 25,
              height: 25,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
