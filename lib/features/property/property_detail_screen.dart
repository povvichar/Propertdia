import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/primary_button.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

const _kTitle = 'Luxury Villa';
const _kPrice = '\$250,000';
const _kTag = 'For Sale';
const _kType = 'Luxury Villa';
const _kAddress = 'No. 45, Street 2008, Phnom Penh Thmei, Sen Sok';
const _kBeds = 5;
const _kBaths = 6;
const _kArea = 420;
const _kDescription =
    'This stunning modern villa features an open-concept design with floor-to-ceiling windows, a private pool, and lush tropical landscaping. Located in the heart of Sen Sok, offering easy access to international schools, restaurants, and business districts.';
const _kAgentName = 'Chan Rithy';
const _kAgentRole = 'Property Consultant';
const _kAgentAvatar =
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80';
const _kFeatures = [
  'Private infinity pool with sun deck',
  'Open-concept kitchen with premium appliances',
  'Home theatre & media room',
  'Smart home automation system',
  '4-car underground garage',
  '24/7 security & CCTV',
];
const _kGallery = [
  'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=900&q=80',
  'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=800&q=80',
  'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
  'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800&q=80',
  'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80',
];

// ── Screen ────────────────────────────────────────────────────────────────────

class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({super.key});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _selectedPhoto = 0;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100 + bottomInset),
          child: Column(
            children: [
              _buildHero(context),
              const _DetailContent(),
            ],
          ),
        ),
        // ── Sticky bottom CTA ─────────────────────────────────────────────
        bottomNavigationBar: _BottomBar(bottomInset: bottomInset),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 310 + topPadding,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _kGallery[_selectedPhoto],
              fit: BoxFit.cover,
              loadingBuilder: (_, child, p) =>
                  p == null ? child : Container(color: AppColors.iconTile),
            ),
          ),
          // Bottom scrim for thumbnail readability.
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 110,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x88000000)],
                ),
              ),
            ),
          ),
          // Gallery thumbnails.
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _kGallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = i == _selectedPhoto;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPhoto = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: selected
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _kGallery[i],
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, p) => p == null
                              ? child
                              : Container(color: AppColors.iconTile),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Back button.
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: _GlassButton(
              asset: 'assets/icons/base/careleft.svg',
              onTap: () => context.pop(),
            ),
          ),
          // Save + share.
          Positioned(
            top: topPadding + 12,
            right: 16,
            child: Row(
              children: [
                _GlassButton(
                  asset: _saved
                      ? 'assets/icons/base/heart_fill.svg'
                      : 'assets/icons/base/heart.svg',
                  color: _saved ? AppColors.gold : AppColors.navy,
                  onTap: () => setState(() => _saved = !_saved),
                ),
                const SizedBox(width: 8),
                _GlassButton(
                  asset: 'assets/icons/base/export.svg',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail content ────────────────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  const _DetailContent();

  static const Color _tagAccent = AppColors.gold;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title + Price ──────────────────────────────────────────
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _kTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    _kPrice,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Tag pill (filled accent — matches PropertyInfoCard) ─────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _tagAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      _kTag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Address ────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/icons/base/map_point.svg',
                    width: 15,
                    height: 15,
                    colorFilter: const ColorFilter.mode(
                        AppColors.textSecondary, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      _kAddress,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Feature tiles ──────────────────────────────────────────
              const _FeatureTilesRow(),
              const SizedBox(height: 20),

              const _Divider(),
              const SizedBox(height: 16),

              // ── Agent ──────────────────────────────────────────────────
              const _AgentRow(),
              const SizedBox(height: 16),

              const _Divider(),
              const SizedBox(height: 18),

              // ── Description ────────────────────────────────────────────
              const Text(
                'About this property',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                _kDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 24),

              // ── Property Features ──────────────────────────────────────
              const Text(
                'Property Features',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              for (final f in _kFeatures)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feature tiles ─────────────────────────────────────────────────────────────

class _FeatureTilesRow extends StatelessWidget {
  const _FeatureTilesRow();

  @override
  Widget build(BuildContext context) {
    const tiles = [
      _TileData('assets/icons/base/house.svg', _kType),
      _TileData('assets/icons/base/bed.svg', '$_kBeds Beds'),
      _TileData('assets/icons/base/bath.svg', '$_kBaths Baths'),
      _TileData('assets/icons/base/maximize.svg', '$_kArea m²'),
    ];

    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _FeatureTile(data: tiles[i])),
        ],
      ],
    );
  }
}

class _TileData {
  const _TileData(this.asset, this.label);
  final String asset;
  final String label;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.data});
  final _TileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            data.asset,
            width: 22,
            height: 22,
            colorFilter:
                const ColorFilter.mode(AppColors.navy, BlendMode.srcIn),
          ),
          const SizedBox(height: 7),
          Text(
            data.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Agent row ─────────────────────────────────────────────────────────────────

class _AgentRow extends StatelessWidget {
  const _AgentRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.iconTile,
          backgroundImage: NetworkImage(_kAgentAvatar),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _kAgentName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                _kAgentRole,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Phone button.
        _ContactIconButton(
          asset: 'assets/icons/base/phone.svg',
          onTap: () {},
        ),
        const SizedBox(width: 10),
        // Telegram button.
        _ContactIconButton(
          asset: 'assets/icons/base/telegram.svg',
          onTap: () {},
          raw: true,
        ),
      ],
    );
  }
}

// ── Bottom CTA bar ────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.bottomInset});
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, bottomInset > 0 ? bottomInset : 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          _ContactIconButton(
            asset: 'assets/icons/base/phone.svg',
            onTap: () {},
            size: 48,
          ),
          const SizedBox(width: 10),
          _ContactIconButton(
            asset: 'assets/icons/base/telegram.svg',
            onTap: () {},
            raw: true,
            size: 48,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: PrimaryButton(
              label: 'Contact Agent',
              trailingIcon: null,
              onPressed: _noop,
            ),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

// ── Shared small widgets ──────────────────────────────────────────────────────

/// Glass circle button for the hero overlay (back / save / share).
class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.asset,
    required this.onTap,
    this.color = AppColors.navy,
  });

  final String asset;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                asset,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circle icon button used in the agent row and bottom bar.
class _ContactIconButton extends StatelessWidget {
  const _ContactIconButton({
    required this.asset,
    required this.onTap,
    this.raw = false,
    this.size = 44,
  });

  final String asset;
  final VoidCallback onTap;
  final bool raw;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: raw
              ? SvgPicture.asset(asset, width: 22, height: 22)
              : SvgPicture.asset(
                  asset,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                      AppColors.navy, BlendMode.srcIn),
                ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}
