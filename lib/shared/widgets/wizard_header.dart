import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'glass_icon_button.dart';

/// Shared header for the multi-step wizard flows (valuation, title, …).
/// Back button + title + "Step n/total" + a segmented progress bar that
/// highlights the current step.
class WizardHeader extends StatelessWidget {
  const WizardHeader({
    super.key,
    required this.title,
    required this.step,
    required this.total,
    required this.onBack,
  });

  final String title;
  final int step;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              GlassIconButton(
                asset: 'assets/icons/base/careleft.svg',
                onTap: onBack,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Text(
                'Step ${step + 1}/$total',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 5,
                    decoration: BoxDecoration(
                      color: i < step
                          ? AppColors.gold
                          : i == step
                              ? AppColors.gold.withValues(alpha: 0.45)
                              : AppColors.iconTile,
                      borderRadius: BorderRadius.circular(3),
                      border: i == step
                          ? Border.all(color: AppColors.gold, width: 1)
                          : null,
                    ),
                  ),
                ),
                if (i < total - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
