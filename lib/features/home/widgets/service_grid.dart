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
  _Service('assets/icons/home/force_sale.svg', 'Force Sale'),
  _Service('assets/icons/home/invest_loan.svg', 'Invest & Loan'),
  _Service('assets/icons/home/partnership.svg', 'Partnership'),
];

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 90,
      ),
      itemCount: _services.length,
      itemBuilder: (context, i) => _ServiceTile(service: _services[i]),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final _Service service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7EC), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              service.asset,
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(
                AppColors.navyIcon,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.label,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
