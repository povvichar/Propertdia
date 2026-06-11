import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/property.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.property, this.width});

  final Property property;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0xB2EEF2FF),
              blurRadius: 3.45,
              spreadRadius: 3.45,
              offset: Offset(0, 0.86),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo with liquid-glass tag overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13.8)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      property.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : Container(color: AppColors.iconTile),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _GlassTag(label: property.tag),
                    ),
                  ],
                ),
              ),
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
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

class _GlassTag extends StatelessWidget {
  const _GlassTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}
