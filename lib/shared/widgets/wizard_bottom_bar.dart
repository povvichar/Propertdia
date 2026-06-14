import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import 'primary_button.dart';

/// Shared sticky bottom bar for the multi-step wizard flows.
/// Optional back chevron + primary action, with an animated [hint] banner
/// above the button explaining why the action is disabled.
class WizardBottomBar extends StatelessWidget {
  const WizardBottomBar({
    super.key,
    required this.showBack,
    required this.onBack,
    required this.label,
    required this.enabled,
    required this.onNext,
    this.hint,
  });

  final bool showBack;
  final VoidCallback onBack;
  final String label;
  final bool enabled;
  final VoidCallback onNext;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: hint != null
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.goldSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.goldDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hint!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Row(
            children: [
              if (showBack) ...[
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    height: 48,
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/base/careleft.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                            AppColors.navy, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: PrimaryButton(
                  label: label,
                  enabled: enabled,
                  onPressed: enabled ? onNext : () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
