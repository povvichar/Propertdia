import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/models/property.dart';
import 'widgets/map_glass.dart';
import 'widgets/price_marker.dart';
import 'widgets/property_info_card.dart';

/// Phnom Penh — used as the "near you" map centre.
const _kUserLocation = LatLng(11.5564, 104.9282);

enum _ListingFilter { all, sale, rent }

class MapPriceScreen extends StatefulWidget {
  const MapPriceScreen({super.key});

  @override
  State<MapPriceScreen> createState() => _MapPriceScreenState();
}

class _MapPriceScreenState extends State<MapPriceScreen> {
  final _mapController = MapController();

  Property? _selected;
  _ListingFilter _filter = _ListingFilter.all;

  List<Property> get _visible => switch (_filter) {
        _ListingFilter.all => mockMapProperties,
        _ListingFilter.sale =>
          mockMapProperties.where((p) => !p.isRent).toList(),
        _ListingFilter.rent =>
          mockMapProperties.where((p) => p.isRent).toList(),
      };

  void _select(Property p) {
    setState(() => _selected = p);
    // Shift centre south so the pin sits above the info card.
    _mapController.move(LatLng(p.lat! - 0.006, p.lng!), 14.2);
  }

  void _dismiss() {
    if (_selected != null) setState(() => _selected = null);
  }

  void _setFilter(_ListingFilter f) {
    setState(() {
      _filter = f;
      if (_selected != null && !_visible.contains(_selected)) {
        _selected = null;
      }
    });
  }

  void _recenter() {
    setState(() => _selected = null);
    _mapController.move(_kUserLocation, 12.6);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    // Selected marker last so it draws on top.
    final ordered = [
      ...visible.where((p) => p.id != _selected?.id),
      if (_selected != null && visible.contains(_selected)) _selected!,
    ];
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final hasCard = _selected != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Map ──────────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _kUserLocation,
                initialZoom: 12.6,
                minZoom: 9,
                maxZoom: 18,
                onTap: (_, __) => _dismiss(),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.propertdia.app',
                  retinaMode: RetinaMode.isHighDensity(context),
                ),
                // User "near you" location.
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: _kUserLocation,
                      width: 26,
                      height: 26,
                      child: _UserDot(),
                    ),
                  ],
                ),
                // Property price pins.
                MarkerLayer(
                  markers: [
                    for (final p in ordered)
                      Marker(
                        point: LatLng(p.lat!, p.lng!),
                        width: 110,
                        height: 52,
                        alignment: Alignment.topCenter,
                        child: PriceMarker(
                          label: p.pinPrice,
                          accent: listingAccent(p),
                          selected: p.id == _selected?.id,
                          onTap: () => _select(p),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Soft scrim behind the top controls for legibility.
            IgnorePointer(
              child: Container(
                height: MediaQuery.paddingOf(context).top + 150,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),

            // ── Top controls ────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlassCircleButton(
                          asset: 'assets/icons/base/careleft.svg',
                          onTap: () => context.pop(),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: _SearchField()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FilterChips(filter: _filter, onChanged: _setFilter),
                  ],
                ),
              ),
            ),

            // ── Recenter button ─────────────────────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              right: 16,
              bottom: (hasCard ? 232 : 28) + safeBottom,
              child: GlassCircleButton(
                asset: 'assets/icons/base/target.svg',
                onTap: _recenter,
                size: 46,
              ),
            ),

            // ── Listing count pill ──────────────────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: 16,
              bottom: (hasCard ? 232 : 28) + safeBottom,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasCard ? 0 : 1,
                child: GlassSurface(
                  radius: 20,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Text(
                    '${visible.length} properties near you',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),

            // ── Property info card ──────────────────────────────────────
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + safeBottom,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: _selected == null
                    ? const SizedBox.shrink()
                    : PropertyInfoCard(
                        key: ValueKey(_selected!.id),
                        property: _selected!,
                        onClose: _dismiss,
                        onOpen: () => context.push('/property'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing-style "you are here" dot.
class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _focused
                  ? AppColors.gold
                  : Colors.white.withValues(alpha: 0.7),
              width: _focused ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _focused
                    ? AppColors.gold.withValues(alpha: 0.22)
                    : AppColors.navy.withValues(alpha: 0.08),
                blurRadius: _focused ? 14 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/base/search.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  _focused ? AppColors.gold : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  focusNode: _focus,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search area, district, coordinates',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  contextMenuBuilder: (_, __) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/base/slidershorizontal.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  _focused ? AppColors.gold : AppColors.navy,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.onChanged});

  final _ListingFilter filter;
  final ValueChanged<_ListingFilter> onChanged;

  static const _labels = {
    _ListingFilter.all: 'All',
    _ListingFilter.sale: 'For Sale',
    _ListingFilter.rent: 'For Rent',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          for (final f in _ListingFilter.values) ...[
            _Chip(
              label: _labels[f]!,
              selected: f == filter,
              onTap: () => onChanged(f),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: selected
          ? Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : GlassSurface(
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
    );
  }
}
