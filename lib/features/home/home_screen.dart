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
                const SizedBox(height: 22),
                const ServiceGrid(),
                const SizedBox(height: 26),
                const _SectionTitle(title: 'Best Price'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 215,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mockBestPrice.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) =>
                        PropertyCard(property: mockBestPrice[i], width: 168),
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

class _HeroSlide {
  const _HeroSlide(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

const _heroSlides = [
  _HeroSlide(
    'Discover Your Dream Property',
    'Browse houses, condos & lands across Cambodia.',
  ),
  _HeroSlide(
    'Real Prices on the Map',
    'Live market prices and trends by area.',
  ),
  _HeroSlide(
    'Trusted Title Services',
    'Verify ownership with local experts.',
  ),
];

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 182,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image layer — swipes between slides
          PageView.builder(
            controller: _controller,
            itemCount: _heroSlides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, __) => const Image(
              image: AssetImage('assets/images/banner.png'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          // Text crossfades on page change
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 340),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _HeroBannerText(
              key: ValueKey(_page),
              slide: _heroSlides[_page],
            ),
          ),
          // Dot indicators
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _heroSlides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 26 : 18,
                    height: 5,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.gold : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBannerText extends StatelessWidget {
  const _HeroBannerText({super.key, required this.slide});

  final _HeroSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              slide.title,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              slide.subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 17,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            'See all',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
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
