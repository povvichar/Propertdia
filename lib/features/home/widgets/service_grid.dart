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
    return Column(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 86,
              alignment: Alignment.center,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.iconTile,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child:
                    SvgPicture.asset(service.asset, width: 26, height: 26),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Scale down slightly on narrow screens so labels never truncate.
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
    );
  }
}
