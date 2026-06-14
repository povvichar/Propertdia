import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/property.dart';

class PropertyCard extends StatefulWidget {
  const PropertyCard({super.key, required this.property, this.width});

  final Property property;
  final double? width;

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final accent = p.isRent ? AppColors.info : AppColors.gold;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => context.push('/property'),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo ──────────────────────────────────────────────────
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
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
                      const DecoratedBox(
                        decoration:
                            BoxDecoration(gradient: AppColors.photoOverlay),
                      ),
                      // Accent tag — colour encodes sale vs rent.
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _AccentTag(label: p.tag, accent: accent),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Info ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
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
                    const SizedBox(height: 3),

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
                    const SizedBox(height: 8),

                    // Price + specs
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p.price,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        if (p.beds > 0) ...[
                          _SpecChip(
                            asset: 'assets/icons/base/bed.svg',
                            value: '${p.beds}',
                          ),
                          const SizedBox(width: 8),
                          _SpecChip(
                            asset: 'assets/icons/base/bath.svg',
                            value: '${p.baths}',
                          ),
                        ],
                      ],
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

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.asset, required this.value});

  final String asset;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: 13,
          height: 13,
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

/// Small filled accent pill on the photo — gold=sale, blue=rent.
class _AccentTag extends StatelessWidget {
  const _AccentTag({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isGold = accent == AppColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: isGold ? AppColors.navy : Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
