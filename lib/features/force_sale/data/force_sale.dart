import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum SaleType { bankOwned, auction, urgent, distressed }

extension SaleTypeX on SaleType {
  String get label => switch (this) {
        SaleType.bankOwned => 'Bank-owned',
        SaleType.auction => 'Auction',
        SaleType.urgent => 'Urgent Sale',
        SaleType.distressed => 'Distressed',
      };

  Color get color => switch (this) {
        SaleType.bankOwned => const Color(0xFF0061A8),
        SaleType.auction => AppColors.gold,
        SaleType.urgent => AppColors.danger,
        SaleType.distressed => const Color(0xFFEA6A1E),
      };
}

class ForceSaleProperty {
  const ForceSaleProperty({
    required this.id,
    required this.title,
    required this.location,
    required this.province,
    required this.propertyType,
    required this.saleType,
    required this.reason,
    required this.askingPrice,
    required this.marketPrice,
    required this.beds,
    required this.baths,
    required this.areaSqm,
    required this.daysLeft,
    required this.imageUrl,
    required this.agentName,
    required this.agentContact,
    this.gallery = const [],
    this.lat,
    this.lng,
  });

  final String id;
  final String title;
  final String location;
  final String province;
  final String propertyType;
  final SaleType saleType;
  final String reason;
  final int askingPrice;
  final int marketPrice;
  final int beds;
  final int baths;
  final int areaSqm;
  final int daysLeft;
  final String imageUrl;
  final String agentName;
  final String agentContact;
  final List<String> gallery;
  final double? lat;
  final double? lng;

  int get discountPct => marketPrice <= 0
      ? 0
      : (((marketPrice - askingPrice) / marketPrice) * 100).round();
}

String usd(int v) {
  final s = v.toString();
  final b = StringBuffer(r'$');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

// ── Filtering ───────────────────────────────────────────────────────────────

class ForceSaleFilter {
  const ForceSaleFilter({
    this.propertyTypes = const {},
    this.minDiscount = 0,
    this.priceBucket = 'any',
    this.minBeds = 0,
  });

  final Set<String> propertyTypes;
  final int minDiscount; // 0 / 10 / 20 / 30
  final String priceBucket; // any / lt100 / mid / gt300
  final int minBeds; // 0..4

  bool get isEmpty =>
      propertyTypes.isEmpty &&
      minDiscount == 0 &&
      priceBucket == 'any' &&
      minBeds == 0;

  int get activeCount =>
      (propertyTypes.isEmpty ? 0 : 1) +
      (minDiscount > 0 ? 1 : 0) +
      (priceBucket == 'any' ? 0 : 1) +
      (minBeds > 0 ? 1 : 0);

  bool matches(ForceSaleProperty p) {
    if (propertyTypes.isNotEmpty && !propertyTypes.contains(p.propertyType)) {
      return false;
    }
    if (p.discountPct < minDiscount) return false;
    if (p.beds < minBeds) return false;
    switch (priceBucket) {
      case 'lt100':
        if (p.askingPrice >= 100000) return false;
      case 'mid':
        if (p.askingPrice < 100000 || p.askingPrice > 300000) return false;
      case 'gt300':
        if (p.askingPrice <= 300000) return false;
    }
    return true;
  }

  ForceSaleFilter copyWith({
    Set<String>? propertyTypes,
    int? minDiscount,
    String? priceBucket,
    int? minBeds,
  }) =>
      ForceSaleFilter(
        propertyTypes: propertyTypes ?? this.propertyTypes,
        minDiscount: minDiscount ?? this.minDiscount,
        priceBucket: priceBucket ?? this.priceBucket,
        minBeds: minBeds ?? this.minBeds,
      );
}

const kForceSalePropertyTypes = [
  'Villa',
  'Condo',
  'Apartment',
  'Shophouse',
  'Land',
  'Borey House',
];

// ── Saved / monitored opportunities (shared across screens) ──────────────────

class SavedStore extends ChangeNotifier {
  final Set<String> _ids = {};

  bool contains(String id) => _ids.contains(id);
  int get count => _ids.length;

  void toggle(String id) {
    _ids.contains(id) ? _ids.remove(id) : _ids.add(id);
    notifyListeners();
  }
}

final savedForceSale = SavedStore();

// ── Mock distressed marketplace (Cambodia-wide) ──────────────────────────────

const mockForceSale = <ForceSaleProperty>[
  ForceSaleProperty(
    id: 'f1',
    title: 'Repossessed Pool Villa',
    location: 'Chamkarmon, Phnom Penh',
    province: 'Phnom Penh',
    propertyType: 'Villa',
    saleType: SaleType.bankOwned,
    reason: 'Bank repossession · clear Hard Title',
    askingPrice: 318000,
    marketPrice: 465000,
    beds: 4,
    baths: 5,
    areaSqm: 380,
    daysLeft: 6,
    imageUrl:
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=900&q=80',
    agentName: 'Chan Rithy',
    agentContact: '@chanrithy',
    lat: 11.5430,
    lng: 104.9220,
  ),
  ForceSaleProperty(
    id: 'f2',
    title: 'Auction Riverside Condo',
    location: 'Daun Penh, Phnom Penh',
    province: 'Phnom Penh',
    propertyType: 'Condo',
    saleType: SaleType.auction,
    reason: 'Court-ordered auction · reserve set',
    askingPrice: 132000,
    marketPrice: 168000,
    beds: 2,
    baths: 2,
    areaSqm: 92,
    daysLeft: 12,
    imageUrl:
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=900&q=80',
    agentName: 'Sophea Lim',
    agentContact: '+855 12 345 678',
    lat: 11.5715,
    lng: 104.9305,
  ),
  ForceSaleProperty(
    id: 'f3',
    title: 'Urgent Sale Borey House',
    location: 'Sen Sok, Phnom Penh',
    province: 'Phnom Penh',
    propertyType: 'Borey House',
    saleType: SaleType.urgent,
    reason: 'Owner relocating abroad · must sell',
    askingPrice: 148000,
    marketPrice: 205000,
    beds: 4,
    baths: 4,
    areaSqm: 160,
    daysLeft: 3,
    imageUrl:
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=900&q=80',
    agentName: 'Dara Kim',
    agentContact: '@darakim',
    lat: 11.6052,
    lng: 104.8985,
  ),
  ForceSaleProperty(
    id: 'f4',
    title: 'Distressed Beachfront Land',
    location: 'Sangkat 4, Sihanoukville',
    province: 'Preah Sihanouk',
    propertyType: 'Land',
    saleType: SaleType.distressed,
    reason: 'Stalled project · liquidation',
    askingPrice: 92000,
    marketPrice: 150000,
    beds: 0,
    baths: 0,
    areaSqm: 640,
    daysLeft: 9,
    imageUrl:
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&q=80',
    agentName: 'Visal Chea',
    agentContact: '@visalchea',
    lat: 10.6270,
    lng: 103.5220,
  ),
  ForceSaleProperty(
    id: 'f5',
    title: 'Bank-owned Shophouse',
    location: 'Svay Por, Battambang',
    province: 'Battambang',
    propertyType: 'Shophouse',
    saleType: SaleType.bankOwned,
    reason: 'Foreclosed · ready to transfer',
    askingPrice: 78000,
    marketPrice: 112000,
    beds: 3,
    baths: 2,
    areaSqm: 150,
    daysLeft: 18,
    imageUrl:
        'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=900&q=80',
    agentName: 'Nida Sok',
    agentContact: '+855 70 123 456',
    lat: 13.0957,
    lng: 103.2022,
  ),
  ForceSaleProperty(
    id: 'f6',
    title: 'Urgent City Apartment',
    location: 'Svay Dangkum, Siem Reap',
    province: 'Siem Reap',
    propertyType: 'Apartment',
    saleType: SaleType.urgent,
    reason: 'Medical emergency · quick close',
    askingPrice: 64000,
    marketPrice: 89000,
    beds: 2,
    baths: 1,
    areaSqm: 74,
    daysLeft: 4,
    imageUrl:
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=900&q=80',
    agentName: 'Sophea Lim',
    agentContact: '@sophea',
    lat: 13.3633,
    lng: 103.8564,
  ),
];
