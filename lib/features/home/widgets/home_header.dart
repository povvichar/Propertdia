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
                              fontSize: 14,
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
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeaderAction(
                  child: SvgPicture.asset(
                    'assets/icons/base/plus.svg',
                    width: 22,
                    height: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Image(
                  image: AssetImage('assets/images/logo_mark.png'),
                  width: 30,
                  height: 30,
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

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.iconTile,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
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
        SvgPicture.asset('assets/icons/base/bell.svg', width: 26, height: 26),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.gold,
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
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search condo, borey, land...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SvgPicture.asset(
            'assets/icons/base/search.svg',
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
