import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ValuationType { land, building }

enum ValuationStatus { requested, inReview, approved, rejected, completed }

enum ValuationPurpose { sale, mortgage, legal, personal }

enum ContactMethod { telegram, phone }

extension ValuationTypeX on ValuationType {
  String get label =>
      this == ValuationType.land ? 'Land Valuation' : 'Building Valuation';
  String get short => this == ValuationType.land ? 'Land' : 'Building';
  String get asset => this == ValuationType.land
      ? 'assets/icons/base/land.svg'
      : 'assets/icons/base/building.svg';

  /// Service fee in USD.
  int get fee => this == ValuationType.land ? 49 : 79;
}

extension ValuationPurposeX on ValuationPurpose {
  String get label => switch (this) {
        ValuationPurpose.sale => 'Sale / Listing',
        ValuationPurpose.mortgage => 'Mortgage / Loan',
        ValuationPurpose.legal => 'Legal / Title',
        ValuationPurpose.personal => 'Personal Record',
      };
  String get asset => switch (this) {
        ValuationPurpose.sale => 'assets/icons/base/tag_price.svg',
        ValuationPurpose.mortgage => 'assets/icons/base/wallet.svg',
        ValuationPurpose.legal => 'assets/icons/base/certificate.svg',
        ValuationPurpose.personal => 'assets/icons/base/profile.svg',
      };
}

extension ValuationStatusX on ValuationStatus {
  String get label => switch (this) {
        ValuationStatus.requested => 'Requested',
        ValuationStatus.inReview => 'In Review',
        ValuationStatus.approved => 'Approved',
        ValuationStatus.rejected => 'Rejected',
        ValuationStatus.completed => 'Completed',
      };

  Color get color => switch (this) {
        ValuationStatus.requested => const Color(0xFF0088FF),
        ValuationStatus.inReview => const Color(0xFFF3A218),
        ValuationStatus.approved => const Color(0xFF0F973D),
        ValuationStatus.rejected => AppColors.danger,
        ValuationStatus.completed => const Color(0xFF0F973D),
      };

  /// Index along the happy-path timeline (Requested → … → Completed).
  int get step => switch (this) {
        ValuationStatus.requested => 0,
        ValuationStatus.inReview => 1,
        ValuationStatus.approved => 2,
        ValuationStatus.rejected => 2,
        ValuationStatus.completed => 3,
      };
}

class Valuation {
  const Valuation({
    required this.id,
    required this.refNo,
    required this.type,
    required this.status,
    required this.address,
    required this.district,
    required this.purpose,
    required this.propertyType,
    required this.contactMethod,
    required this.contactInfo,
    required this.submittedDate,
    this.landSize,
    this.buildingSize,
    this.beds,
    this.baths,
    this.estimatedValue,
    this.valueLow,
    this.valueHigh,
    this.comparables = 0,
    this.photoCount = 0,
  });

  final String id;
  final String refNo;
  final ValuationType type;
  final ValuationStatus status;
  final String address;
  final String district;
  final ValuationPurpose purpose;
  final String propertyType;
  final ContactMethod contactMethod;
  final String contactInfo;
  final DateTime submittedDate;
  final String? landSize;
  final String? buildingSize;
  final int? beds;
  final int? baths;
  final int? estimatedValue;
  final int? valueLow;
  final int? valueHigh;
  final int comparables;
  final int photoCount;

  bool get hasValue => estimatedValue != null &&
      (status == ValuationStatus.approved ||
          status == ValuationStatus.completed);
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

String shortDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

const kDistricts = [
  'Daun Penh',
  'Chamkarmon',
  'BKK1',
  'Tonle Bassac',
  'Tuol Kork',
  'Sen Sok',
  'Chroy Changvar',
  'Mean Chey',
  'Por Senchey',
];

const kLandTitles = ['Hard Title', 'Soft Title', 'LMAP Title'];

/// Cambodian bank / wallet payment channels.
class BankOption {
  const BankOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.logoAsset,
    required this.logoBg,
  });

  final String id;
  final String name;
  final String subtitle;
  final String logoAsset;

  /// Badge background — dark for white wordmarks (ABA), light for full-color logos.
  final Color logoBg;
}

const kBanks = [
  BankOption(
    id: 'aba',
    name: 'ABA Bank',
    subtitle: 'Pay with ABA Mobile',
    logoAsset: 'assets/icons/base/aba.svg',
    logoBg: Color(0xFF0A2240),
  ),
  BankOption(
    id: 'acleda',
    name: 'ACLEDA Bank',
    subtitle: 'ACLEDA mobile · XPay',
    logoAsset: 'assets/icons/base/acleda.svg',
    logoBg: Colors.white,
  ),
  BankOption(
    id: 'wing',
    name: 'Wing Bank',
    subtitle: 'Wing account',
    logoAsset: 'assets/icons/base/wing.svg',
    logoBg: Colors.white,
  ),
];

/// Existing valuation requests shown on the hub for progress tracking.
final mockValuations = <Valuation>[
  Valuation(
    id: 'v1',
    refNo: 'VL-2026-0418',
    type: ValuationType.building,
    status: ValuationStatus.completed,
    address: 'No. 12, Street 310, BKK1',
    district: 'BKK1',
    purpose: ValuationPurpose.sale,
    propertyType: 'Villa',
    contactMethod: ContactMethod.telegram,
    contactInfo: '@chanrithy',
    submittedDate: DateTime(2026, 5, 28),
    buildingSize: '320',
    beds: 4,
    baths: 5,
    estimatedValue: 512000,
    valueLow: 485000,
    valueHigh: 540000,
    comparables: 7,
    photoCount: 6,
  ),
  Valuation(
    id: 'v2',
    refNo: 'VL-2026-0521',
    type: ValuationType.land,
    status: ValuationStatus.inReview,
    address: 'Borey Peng Huoth, Street 2011, Sen Sok',
    district: 'Sen Sok',
    purpose: ValuationPurpose.mortgage,
    propertyType: 'Land',
    contactMethod: ContactMethod.phone,
    contactInfo: '+855 12 345 678',
    submittedDate: DateTime(2026, 6, 6),
    landSize: '480',
    comparables: 0,
    photoCount: 4,
  ),
  Valuation(
    id: 'v3',
    refNo: 'VL-2026-0530',
    type: ValuationType.building,
    status: ValuationStatus.approved,
    address: 'Unit 18F, Peak Tower, Tonle Bassac',
    district: 'Tonle Bassac',
    purpose: ValuationPurpose.legal,
    propertyType: 'Condo',
    contactMethod: ContactMethod.telegram,
    contactInfo: '@sophea',
    submittedDate: DateTime(2026, 6, 9),
    buildingSize: '96',
    beds: 2,
    baths: 2,
    estimatedValue: 168000,
    valueLow: 158000,
    valueHigh: 179000,
    comparables: 5,
    photoCount: 5,
  ),
];
