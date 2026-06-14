import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// Re-export shared formatters so screens importing this data file keep usd()/shortDate().
export '../../../shared/utils/format.dart';

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
        ValuationStatus.requested => AppColors.info,
        ValuationStatus.inReview => AppColors.warning,
        ValuationStatus.approved => AppColors.success,
        ValuationStatus.rejected => AppColors.danger,
        ValuationStatus.completed => AppColors.success,
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
    this.province = '',
    required this.purpose,
    required this.propertyType,
    required this.contactMethod,
    required this.contactInfo,
    required this.submittedDate,
    this.applicantName = '',
    this.lat,
    this.lng,
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
  final String province;
  final ValuationPurpose purpose;
  final String propertyType;
  final ContactMethod contactMethod;
  final String contactInfo;
  final DateTime submittedDate;
  final String applicantName;
  final double? lat;
  final double? lng;
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

const kLandTitles = ['Hard Title', 'Soft Title', 'LMAP Title'];

/// Existing valuation requests shown on the hub for progress tracking.
final mockValuations = <Valuation>[
  Valuation(
    id: 'v1',
    refNo: 'VL-2026-0418',
    type: ValuationType.building,
    status: ValuationStatus.completed,
    address: 'No. 12, Street 310, BKK1',
    province: 'Phnom Penh',
    applicantName: 'Chan Rithy',
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
    lat: 11.5486,
    lng: 104.9225,
  ),
  Valuation(
    id: 'v2',
    refNo: 'VL-2026-0521',
    type: ValuationType.land,
    status: ValuationStatus.inReview,
    address: 'National Road 6, Svay Dangkum',
    province: 'Siem Reap',
    applicantName: 'Sophea Lim',
    purpose: ValuationPurpose.mortgage,
    propertyType: 'Land',
    contactMethod: ContactMethod.phone,
    contactInfo: '+855 12 345 678',
    submittedDate: DateTime(2026, 6, 6),
    landSize: '480',
    comparables: 0,
    photoCount: 4,
    lat: 13.3633,
    lng: 103.8564,
  ),
  Valuation(
    id: 'v3',
    refNo: 'VL-2026-0530',
    type: ValuationType.building,
    status: ValuationStatus.approved,
    address: 'Ochheuteal Beach Road, Sangkat 4',
    province: 'Preah Sihanouk',
    applicantName: 'Dara Kim',
    purpose: ValuationPurpose.legal,
    propertyType: 'Condo',
    contactMethod: ContactMethod.telegram,
    contactInfo: '@darakim',
    submittedDate: DateTime(2026, 6, 9),
    buildingSize: '96',
    beds: 2,
    baths: 2,
    estimatedValue: 168000,
    valueLow: 158000,
    valueHigh: 179000,
    comparables: 5,
    photoCount: 5,
    lat: 10.6093,
    lng: 103.5295,
  ),
];
