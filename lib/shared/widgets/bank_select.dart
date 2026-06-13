import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Cambodian bank / wallet payment channel.
class BankOption {
  const BankOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.logoAsset,
    required this.logoBg,
  });

  final String id;
  final String name;
  final String subtitle;
  final String logoAsset;

  /// Badge background — dark for white wordmarks (ABA), light for full-color logos.
  final Color logoBg;
}

const kBanks = [
  BankOption(
    id: 'aba',
    name: 'ABA Bank',
    subtitle: 'Pay with ABA Mobile',
    logoAsset: 'assets/icons/base/aba.svg',
    logoBg: Color(0xFF0A2240),
  ),
  BankOption(
    id: 'acleda',
    name: 'ACLEDA Bank',
    subtitle: 'ACLEDA mobile · XPay',
    logoAsset: 'assets/icons/base/acleda.svg',
    logoBg: Colors.white,
  ),
  BankOption(
    id: 'wing',
    name: 'Wing Bank',
    subtitle: 'Wing account',
    logoAsset: 'assets/icons/base/wing.svg',
    logoBg: Colors.white,
  ),
];

/// Selectable payment-method row with the bank's logo badge.
class BankTile extends StatelessWidget {
  const BankTile({
    super.key,
    required this.bank,
    required this.selected,
    required this.onTap,
  });

  final BankOption bank;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bank.logoBg,
                borderRadius: BorderRadius.circular(12),
                border: bank.logoBg == Colors.white
                    ? Border.all(color: AppColors.border)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: SvgPicture.asset(bank.logoAsset, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bank.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.gold : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
