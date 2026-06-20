import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../invest/widgets/invest_widgets.dart';
import '../../shared/models/property.dart';
import 'data/favorites.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: favoritesStore,
        builder: (context, _) {
          final props = favoritesStore.properties;
          final projects = favoritesStore.projects;
          final showProps = _tab == 0;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Favorites',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${favoritesStore.total} saved items',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedTabs(
                      labels: ['Properties · ${props.length}', 'Invest · ${projects.length}'],
                      index: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: showProps
                    ? _PropertyList(props: props)
                    : _ProjectList(projects: projects),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PropertyList extends StatelessWidget {
  const _PropertyList({required this.props});

  final List props;

  @override
  Widget build(BuildContext context) {
    if (props.isEmpty) {
      return const _Empty(
        icon: 'assets/icons/base/house.svg',
        title: 'No saved properties',
        blurb: 'Tap the heart on any listing to save it here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: props.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _FavPropertyCard(
        property: props[i],
        onUnsave: () => favoritesStore.toggleProperty(props[i]),
      ),
    );
  }
}

// ── Horizontal property card for Favorites ────────────────────────────────────

class _FavPropertyCard extends StatefulWidget {
  const _FavPropertyCard({required this.property, required this.onUnsave});

  final Property property;
  final VoidCallback onUnsave;

  @override
  State<_FavPropertyCard> createState() => _FavPropertyCardState();
}

class _FavPropertyCardState extends State<_FavPropertyCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final isRent = p.isRent;
    final accentColor = isRent ? AppColors.info : AppColors.gold;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => context.push('/property'),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // ── Thumbnail ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          p.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : Container(color: AppColors.iconTile),
                        ),
                        // Accent pill — sale vs rent
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              p.tag,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isRent ? Colors.white : AppColors.navy,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + unsave
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              p.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: widget.onUnsave,
                            child: SvgPicture.asset(
                              'assets/icons/base/heart_fill.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.gold, BlendMode.srcIn),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Location
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/base/map_point.svg',
                            width: 11,
                            height: 11,
                            colorFilter: const ColorFilter.mode(
                                AppColors.textSecondary, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              p.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Price + specs
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            p.price,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Spacer(),
                          if (p.beds > 0) ...[
                            _MiniSpec(
                              asset: 'assets/icons/base/bed.svg',
                              value: '${p.beds}',
                            ),
                            const SizedBox(width: 8),
                            _MiniSpec(
                              asset: 'assets/icons/base/bath.svg',
                              value: '${p.baths}',
                            ),
                            const SizedBox(width: 8),
                          ],
                          _MiniSpec(
                            asset: 'assets/icons/base/arrowsout.svg',
                            value: '${p.areaSqm} m²',
                          ),
                        ],
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

class _MiniSpec extends StatelessWidget {
  const _MiniSpec({required this.asset, required this.value});

  final String asset;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: 12,
          height: 12,
          colorFilter: const ColorFilter.mode(
              AppColors.textSecondary, BlendMode.srcIn),
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProjectList extends StatelessWidget {
  const _ProjectList({required this.projects});

  final List projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const _Empty(
        icon: 'assets/icons/base/suitcase.svg',
        title: 'No saved opportunities',
        blurb: 'Save investment projects to track them here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => ProjectListItem(
        project: projects[i],
        onTap: () => context.push('/invest/detail', extra: projects[i]),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.blurb});

  final String icon;
  final String title;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                      AppColors.textSecondary.withValues(alpha: 0.6),
                      BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              blurb,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
