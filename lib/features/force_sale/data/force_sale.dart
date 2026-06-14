import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// Re-export shared formatters so screens importing this data file keep usd().
export '../../../shared/utils/format.dart';

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
    this.features = const [],
    this.lat,
    this.lng,
  });

  final String id;
  final String title;
  final String location;
  final String province;
  final String propertyType;
  final SaleType saleType;
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
  final List<String> features;
  final double? lat;
  final double? lng;

  List<String> get photos => [
        imageUrl,
        ...gallery.where((photo) => photo != imageUrl),
      ];

  int get discountPct => marketPrice <= 0
      ? 0
      : (((marketPrice - askingPrice) / marketPrice) * 100).round();
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
    askingPrice: 318000,
    marketPrice: 465000,
    beds: 4,
    baths: 5,
    areaSqm: 380,
    daysLeft: 6,
    imageUrl:
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=900&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=900&q=80',
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=900&q=80',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=900&q=80',
    ],
    features: [
      'Private swimming pool',
      'Hard title ready for transfer',
      'Secure gated parking',
      'Modern fitted kitchen',
    ],
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
    askingPrice: 132000,
    marketPrice: 168000,
    beds: 2,
    baths: 2,
    areaSqm: 92,
    daysLeft: 12,
    imageUrl:
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=900&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=900&q=80',
      'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=900&q=80',
      'https://images.unsplash.com/photo-1600607688969-a5bfcd646154?w=900&q=80',
    ],
    features: [
      'River and city views',
      'Private balcony',
      'Resident fitness center',
      '24/7 building security',
    ],
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
    askingPrice: 148000,
    marketPrice: 205000,
    beds: 4,
    baths: 4,
    areaSqm: 160,
    daysLeft: 3,
    imageUrl:
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=900&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?w=900&q=80',
      'https://images.unsplash.com/photo-1600566753051-f0b89df2dd90?w=900&q=80',
      'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=900&q=80',
    ],
    features: [
      'Borey community security',
      'Covered car parking',
      'Spacious family living area',
      'Move-in ready condition',
    ],
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
    askingPrice: 92000,
    marketPrice: 150000,
    beds: 0,
    baths: 0,
    areaSqm: 640,
    daysLeft: 9,
    imageUrl:
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=900&q=80',
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=900&q=80',
      'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=900&q=80',
    ],
    features: [
      'Beachfront access',
      'Road access available',
      'Flat development-ready land',
      'Suitable for hospitality projects',
    ],
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
    askingPrice: 78000,
    marketPrice: 112000,
    beds: 3,
    baths: 2,
    areaSqm: 150,
    daysLeft: 18,
    imageUrl:
        'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?w=900&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600047508788-786f3865b4b9?w=900&q=80',
      'https://images.unsplash.com/photo-1600566752229-250ed79470f8?w=900&q=80',
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=900&q=80',
    ],
    features: [
      'Ground-floor commercial space',
      'Separate upper-floor residence',
      'Street-facing frontage',
      'Ready for title transfer',
    ],
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
    askingPrice: 64000,
    marketPrice: 89000,
    beds: 2,
    baths: 1,
    areaSqm: 74,
    daysLeft: 4,
    imageUrl:
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=900&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=900&q=80',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=900&q=80',
      'https://images.unsplash.com/photo-1560448075-bb485b067938?w=900&q=80',
    ],
    features: [
      'Fully furnished interior',
      'Private balcony',
      'Central city location',
      'Secure resident parking',
    ],
    agentName: 'Sophea Lim',
    agentContact: '@sophea',
    lat: 13.3633,
    lng: 103.8564,
  ),
];
