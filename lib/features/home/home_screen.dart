import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/models/property.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/brand_logo.dart';
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
      body: const _HomeBody(),
      bottomNavigationBar: _BottomNav(
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
                const _HeroBanner(),
                const SizedBox(height: 16),
                const ServiceGrid(),
                const SizedBox(height: 24),
                const _SectionTitle(title: 'Best Price'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 292,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mockBestPrice.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, i) =>
                        PropertyCard(property: mockBestPrice[i], width: 270),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionTitle(title: 'Recommended for You'),
                const SizedBox(height: 12),
                for (final p in mockRecommended) ...[
                  PropertyCard(property: p),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          const Expanded(
            flex: 11,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 8, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Discover Your Dream Property',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Browse houses, condos & lands across Cambodia.',
                    style: TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Image.network(
              'https://images.unsplash.com/photo-1582407947304-fd86f028f716?w=700&q=80',
              fit: BoxFit.cover,
              height: double.infinity,
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.bookmark_rounded, label: 'Favorite'),
    (icon: Icons.movie_rounded, label: 'Media'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: i == current
                                ? AppColors.goldSoft
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _items[i].icon,
                            size: 24,
                            color: i == current
                                ? AppColors.gold
                                : AppColors.navyIcon.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _items[i].label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == current
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: i == current
                                ? AppColors.gold
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small gold brand mark used in the header action row.
class HeaderBrandMark extends StatelessWidget {
  const HeaderBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrandLogo(size: 28, color: AppColors.gold);
  }
}
