import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/primary_button.dart';
import 'data/force_sale.dart';

class ForceSaleDetailScreen extends StatefulWidget {
  const ForceSaleDetailScreen({super.key, required this.property});

  final ForceSaleProperty property;

  @override
  State<ForceSaleDetailScreen> createState() => _ForceSaleDetailScreenState();
}

class _ForceSaleDetailScreenState extends State<ForceSaleDetailScreen> {
  int _selectedPhoto = 0;

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        content: Text(msg),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final topPad = MediaQuery.paddingOf(context).top;
    final heroH = 280.0 + topPad;
    final isLand = p.beds == 0 && p.baths == 0;
    final saving = p.marketPrice - p.askingPrice;
    final photos = p.photos;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: 100 + MediaQuery.paddingOf(context).bottom),
          child: Column(
            children: [
              SizedBox(
                height: heroH,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        photos[_selectedPhoto],
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, prog) => prog == null
                            ? child
                            : Container(color: AppColors.iconTile),
                      ),
                    ),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x88000000)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 38,
                      left: 16,
                      right: 16,
                      child: SizedBox(
                        height: 52,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final selected = index == _selectedPhoto;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPhoto = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    photos[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) =>
                                        progress == null
                                            ? child
                                            : Container(
                                                color: AppColors.iconTile),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: topPad + 12,
                      left: 16,
                      child: _GlassCircle(
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 17, color: AppColors.navy),
                        onTap: () => context.pop(),
                      ),
                    ),
                    Positioned(
                      top: topPad + 12,
                      right: 16,
                      child: AnimatedBuilder(
                        animation: savedForceSale,
                        builder: (_, __) {
                          final saved = savedForceSale.contains(p.id);
                          return _GlassCircle(
                            onTap: () => savedForceSale.toggle(p.id),
                            child: SvgPicture.asset(
                              saved
                                  ? 'assets/icons/base/heart_fill.svg'
                                  : 'assets/icons/base/heart.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                saved ? AppColors.gold : AppColors.navy,
                                BlendMode.srcIn,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Tag(color: p.saleType.color, label: p.saleType.label),
                        const SizedBox(height: 12),
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/base/map_point.svg',
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.textSecondary, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                p.location,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _PriceCard(
                            asking: p.askingPrice,
                            market: p.marketPrice,
                            discount: p.discountPct,
                            saving: saving),
                        const SizedBox(height: 18),
                        // Specs
                        Row(
                          children: [
                            if (!isLand) ...[
                              _SpecTile(
                                  asset: 'assets/icons/base/bed.svg',
                                  label: '${p.beds} Beds'),
                              const SizedBox(width: 8),
                              _SpecTile(
                                  asset: 'assets/icons/base/bath.svg',
                                  label: '${p.baths} Baths'),
                              const SizedBox(width: 8),
                            ],
                            _SpecTile(
                                asset: 'assets/icons/base/maximize.svg',
                                label: '${p.areaSqm} m²'),
                            const SizedBox(width: 8),
                            _SpecTile(
                                asset: 'assets/icons/base/house.svg',
                                label: p.propertyType),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (p.features.isNotEmpty) ...[
                          const Text(
                            'Property Features',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final feature in p.features)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '•  ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                        _EmergencyContact(
                          agentName: p.agentName,
                          onCall: () => _toast('Calling emergency hotline…'),
                          onTelegram: () => _toast('Opening Telegram…'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _BottomBar(
            asking: p.askingPrice,
            onOffer: () => _toast('Offer flow — coming soon'),
          ),
        ),
          ],
        ),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7), width: 1),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.asking,
    required this.market,
    required this.discount,
    required this.saving,
  });

  final int asking;
  final int market;
  final int discount;
  final int saving;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.navyDepth,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                usd(asking),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  usd(market),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-$discount%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.trending_down_rounded,
                  size: 16, color: Color(0xFF4ADE80)),
              const SizedBox(width: 6),
              Text(
                '${usd(saving)} below market value',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4ADE80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              asset,
              width: 21,
              height: 21,
              colorFilter:
                  const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  const _EmergencyContact({
    required this.agentName,
    required this.onCall,
    required this.onTelegram,
  });

  final String agentName;
  final VoidCallback onCall;
  final VoidCallback onTelegram;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency support',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Agent $agentName · 24/7 fast response',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onCall,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/base/phone.svg',
                  width: 24,
                  height: 24,
                  colorFilter:
                      const ColorFilter.mode(AppColors.navy, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onTelegram,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/base/telegram.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.asking, required this.onOffer});

  final int asking;
  final VoidCallback onOffer;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              16, 14, 16, bottomInset > 0 ? bottomInset : 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.7), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Asking price',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                usd(asking),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
              child: PrimaryButton(label: 'Make an offer', onPressed: onOffer)),
        ],
          ),
        ),
      ),
    );
  }
}
