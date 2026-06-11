import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

/// Light header: location selector on the left, quick actions on the right,
/// white search pill below.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Current Location',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/icons/base/caretdown.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Phnom Penh',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/base/add_circle.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 14),
                const Image(
                  image: AssetImage('assets/images/logo_mark.png'),
                  width: 24,
                  height: 24,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 14),
                const _NotificationBell(),
              ],
            ),
            const SizedBox(height: 18),
            const _SearchBar(),
          ],
        ),
      ),
    );
  }
}


class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset('assets/icons/base/bell.svg', width: 24, height: 24),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search condo, borey, land...',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: SvgPicture.asset(
              'assets/icons/base/search.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 46),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: const BorderSide(color: Color(0xFFE7E7EC), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: const BorderSide(color: Color(0xFFE7E7EC), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: const BorderSide(color: Color(0xFFE7E7EC), width: 1),
          ),
        ),
      ),
    );
  }
}
