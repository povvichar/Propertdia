import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class _Service {
  const _Service(this.asset, this.label, {this.multiColor = false, this.route});

  final String asset;
  final String label;
  final bool multiColor;
  final String? route;
}

const _services = [
  _Service('assets/icons/home/map_price.svg', 'Map Price', route: '/map-price'),
  _Service('assets/icons/home/property_estimate.svg', 'Estimate',
      route: '/estimate'),
  _Service('assets/icons/home/title_services.svg', 'Title Services',
      route: '/title'),
  _Service('assets/icons/home/force_sale.svg', 'Force Sale',
      route: '/force-sale'),
  _Service('assets/icons/home/invest_loan.svg', 'Invest & Loan',
      route: '/invest'),
  _Service('assets/icons/home/partnership.svg', 'Partnership',
      multiColor: true, route: '/partnership'),
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
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 78,
      ),
      itemCount: _services.length,
      itemBuilder: (context, i) => _ServiceTile(service: _services[i]),
    );
  }
}

class _ServiceTile extends StatefulWidget {
  const _ServiceTile({required this.service});

  final _Service service;

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        final route = widget.service.route;
        if (route != null) context.push(route);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.service.multiColor
                  ? Opacity(
                      opacity: _pressed ? 0.6 : 1.0,
                      child: SvgPicture.asset(
                        widget.service.asset,
                        width: 24,
                        height: 24,
                      ),
                    )
                  : SvgPicture.asset(
                      widget.service.asset,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        _pressed ? AppColors.gold : AppColors.navyIcon,
                        BlendMode.srcIn,
                      ),
                    ),
              const SizedBox(height: 6),
              Text(
                widget.service.label,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _pressed ? AppColors.navy : AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
