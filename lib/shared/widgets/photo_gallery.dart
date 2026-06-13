import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Grid photo uploader — an "Add" tile plus removable thumbnails.
/// The parent owns the [photos] list (image urls) and mutates it via callbacks.
class PhotoGalleryField extends StatelessWidget {
  const PhotoGalleryField({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemoveAt,
    this.max = 8,
  });

  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveAt;
  final int max;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        if (photos.length < max)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/base/camera.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                          AppColors.navyIcon, BlendMode.srcIn),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        for (var i = 0; i < photos.length; i++)
          Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  photos[i],
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, p) =>
                      p == null ? child : Container(color: AppColors.iconTile),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onRemoveAt(i),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
