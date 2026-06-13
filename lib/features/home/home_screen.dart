import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/models/property.dart';
import '../../shared/providers/app_providers.dart';
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
      body: const _HomeBody(),
      bottomNavigationBar: _GlassNav(
        current: tab,
        onChanged: (i) {
          if (i == 3) {
            context.push('/register');
          } else {
            ref.read(homeTabProvider.notifier).state = i;
          }
        },
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
                const _SectionTitle(title: 'Best Price'),
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

const _navItems = [
  _NavItem('assets/icons/base/home.svg', 'Home'),
  _NavItem('assets/icons/base/bookmark.svg', 'Favorite'),
  _NavItem('assets/icons/base/clapperboard.svg', 'Media'),
  _NavItem('assets/icons/base/profile.svg', 'Profile'),
];

class _GlassNav extends StatelessWidget {
  const _GlassNav({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset > 0 ? bottomInset : 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                for (var i = 0; i < _navItems.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onChanged(i),
                      borderRadius: BorderRadius.circular(38),
                      child: _GlassNavItem(
                        item: _navItems[i],
                        active: i == current,
                      ),
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
  const _GlassNavItem({required this.item, required this.active});

  final _NavItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: 44,
          height: 30,
          decoration: BoxDecoration(
            color: active
                ? AppColors.navy.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: AnimatedScale(
            scale: active ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: SvgPicture.asset(
              item.asset,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                active ? AppColors.navy : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.navy : AppColors.textSecondary,
          ),
          child: Text(item.label),
        ),
      ],
    );
  }
}
