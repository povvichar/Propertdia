import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/property.dart';

/// Accent for a listing — gold for sale, blue for rent.
Color listingAccent(Property p) =>
    p.isRent ? const Color(0xFF0088FF) : AppColors.gold;

/// Floating card shown when a map property pin is tapped.
/// Thumbnail, title, price, sale/rent tag, bed/bath/area, agent + contacts.
class PropertyInfoCard extends StatelessWidget {
  const PropertyInfoCard({
    super.key,
    required this.property,
    required this.onClose,
    required this.onOpen,
  });

  final Property property;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = listingAccent(property);

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Image.network(
                        property.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, p) => p == null
                            ? child
                            : Container(color: AppColors.iconTile),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _TagPill(label: property.tag, accent: accent),
                            const Spacer(),
                            GestureDetector(
                              onTap: onClose,
                              behavior: HitTestBehavior.opaque,
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          property.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          property.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            _Spec(
                              asset: 'assets/icons/base/bed.svg',
                              value: '${property.beds}',
                            ),
                            const SizedBox(width: 14),
                            _Spec(
                              asset: 'assets/icons/base/bath.svg',
                              value: '${property.baths}',
                            ),
                            const SizedBox(width: 14),
                            _Spec(
                              asset: 'assets/icons/base/maximize.svg',
                              value: '${property.areaSqm} m²',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F6)),
              const SizedBox(height: 12),
              // Agent + contacts
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.iconTile,
                    backgroundImage: property.agentAvatar != null
                        ? NetworkImage(property.agentAvatar!)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.agentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          property.agentRole,
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
                  _ContactButton(
                    asset: 'assets/icons/base/phone.svg',
                    onTap: () {},
                  ),
                  const SizedBox(width: 14),
                  _ContactButton(
                    asset: 'assets/icons/base/telegram.svg',
                    raw: true,
                    onTap: () {},
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

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: accent == AppColors.gold ? AppColors.goldDark : accent,
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.asset, required this.value});

  final String asset;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          asset,
          width: 15,
          height: 15,
          colorFilter:
              const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.asset,
    required this.onTap,
    this.raw = false,
  });

  final String asset;
  final VoidCallback onTap;
  final bool raw;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: raw
          ? SvgPicture.asset(asset, width: 26, height: 26)
          : SvgPicture.asset(
              asset,
              width: 26,
              height: 26,
              colorFilter:
                  const ColorFilter.mode(AppColors.navy, BlendMode.srcIn),
            ),
    );
  }
}
