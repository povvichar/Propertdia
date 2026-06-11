import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

class _Service {
  const _Service(this.asset, this.label);

  final String asset;
  final String label;
}

const _services = [
  _Service('assets/icons/home/map_price.svg', 'Map Price'),
  _Service('assets/icons/home/property_estimate.svg', 'Estimate'),
  _Service('assets/icons/home/title_services.svg', 'Title Services'),
  _Service('assets/icons/home/invest_loan.svg', 'Invest & Loan'),
];

/// Single row of four service shortcuts: white card with the icon,
/// label below the card.
class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _services.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _ServiceTile(service: _services[i])),
        ],
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final _Service service;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          SvgPicture.asset(service.asset, width: 40, height: 40),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              service.label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
