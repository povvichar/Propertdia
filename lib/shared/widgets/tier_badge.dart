import 'package:flutter/material.dart';

import '../../features/invest/data/invest.dart';

/// Metal-tinted rank pill (Silver / Gold / Platinum) — a colored dot + label.
/// Used on the wallet balance card, the portfolio tier card and the profile
/// header. Pass [onDark] when placing it on a dark surface so the soft fill
/// gives way to a translucent tint with light text.
class TierBadge extends StatelessWidget {
  const TierBadge(this.tier, {super.key, this.compact = false, this.onDark = false});

  final InvestorTier tier;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = tier.color;
    final fill = onDark ? c.withValues(alpha: 0.18) : tier.colorSoft;
    final fg = onDark ? Colors.white : c;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            compact
                ? tier.label.toUpperCase()
                : '${tier.label.toUpperCase()} INVESTOR',
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
