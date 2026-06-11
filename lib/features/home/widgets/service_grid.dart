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
  _Service('assets/icons/home/property_estimate.svg', 'Property Estimate'),
  _Service('assets/icons/home/title_services.svg', 'Title Services'),
  _Service('assets/icons/home/force_sale.svg', 'Force Sale'),
  _Service('assets/icons/home/invest_loan.svg', 'Invest & Loan'),
  _Service('assets/icons/home/partnership.svg', 'Partnership'),
];

/// 3x2 grid of primary service shortcuts.
class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, i) => _ServiceTile(service: _services[i]),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final _Service service;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.iconTile,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(service.asset, width: 28, height: 28),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  service.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
