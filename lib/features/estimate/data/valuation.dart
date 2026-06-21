import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// Re-export shared formatters so screens importing this data file keep usd()/shortDate().
export '../../../shared/utils/format.dart';

enum ValuationType { land, building }

enum ValuationStatus { requested, inReview, approved, rejected, completed }

enum ValuationPurpose { sale, mortgage, legal, personal }

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

/// Itemised valuation service fee. [ValuationType.fee] is the base/anchor (the
/// "from" price shown while browsing); size, an out-of-Phnom-Penh site visit,
/// and a certified-report purpose (mortgage/legal) add to it.
class ValuationQuote {
  const ValuationQuote({
    required this.base,
    required this.sizeAddon,
    required this.locationAddon,
    required this.certifiedAddon,
  });

  final int base;
  final int sizeAddon;
  final int locationAddon;
  final int certifiedAddon;

  int get total => base + sizeAddon + locationAddon + certifiedAddon;
}

/// Computes the hybrid valuation fee from the request inputs. A valuation can't
/// be priced on the property's *value* (that's the deliverable), so it's priced
/// on observable inputs: size, location, and purpose.
ValuationQuote valuationQuote({
  required ValuationType type,
  double? areaSqm,
  String? province,
  ValuationPurpose? purpose,
}) {
  final base = type.fee;

  final a = areaSqm ?? 0;
  final sizeAddon = a <= 100
      ? 0
      : a <= 300
          ? 30
          : a <= 800
              ? 70
              : 120;

  final locationAddon =
      (province != null && province.isNotEmpty && province != 'Phnom Penh')
          ? 20
          : 0;

  final certified = purpose == ValuationPurpose.mortgage ||
      purpose == ValuationPurpose.legal;
  final certifiedAddon =
      certified ? ((base + sizeAddon + locationAddon) * 0.3).round() : 0;

  return ValuationQuote(
    base: base,
    sizeAddon: sizeAddon,
    locationAddon: locationAddon,
    certifiedAddon: certifiedAddon,
  );
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

  /// Any estimate is attached (indicative on submit, certified once reviewed).
  bool get hasEstimate => estimatedValue != null;

  /// Estimate is still the auto-computed indicative figure, not yet certified
  /// by a human valuer.
  bool get isIndicative =>
      status == ValuationStatus.requested ||
      status == ValuationStatus.inReview;

  /// A certified figure is available (valuer approved/completed the request).
  bool get hasValue => estimatedValue != null &&
      (status == ValuationStatus.approved ||
          status == ValuationStatus.completed);
}

/// Partially-filled inputs carried from the free Instant Estimate into the paid
/// Professional Valuation wizard, so the user doesn't re-enter anything.
class EstimatePrefill {
  const EstimatePrefill({
    required this.type,
    this.province,
    this.propertyType,
    this.size,
    this.beds,
    this.baths,
    this.landTitle,
    this.purpose,
  });

  final ValuationType type;
  final String? province;
  final String? propertyType;
  final String? size;
  final int? beds;
  final int? baths;
  final String? landTitle;
  final ValuationPurpose? purpose;
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
    contactInfo: '+855 12 345 678',
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
    contactInfo: '+855 17 654 321',
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
  ..._generatedValuations(),
];

/// Extra demo valuations so the hub preview + history exercise scroll/filter at
/// volume. Cycles type, status & purpose so every status filter has matches.
List<Valuation> _generatedValuations() {
  const names = [
    'Vannak Chea', 'Bopha Sok', 'Rithy Pen', 'Sreymom Kong', 'Sovann Meas',
    'Pisey Heng', 'Kosal Ny', 'Channary Va', 'Veasna Tep', 'Dalin Sam',
    'Makara Yon', 'Sothea Lim', 'Phalla Roeun', 'Visal Oeur', 'Sokha Chan',
  ];
  const places = <(String, String)>[
    ('Street 271, Sangkat Tomnop Teuk', 'Phnom Penh'),
    ('Wat Bo Road, Sala Kamreuk', 'Siem Reap'),
    ('Mittapheap, Sangkat 4', 'Preah Sihanouk'),
    ('Krong Doun Kaev, Roka Knong', 'Takeo'),
    ('Krong Kampong Cham', 'Kampong Cham'),
    ('Krong Serei Saophoan', 'Banteay Meanchey'),
    ('Svay Por, Krong Battambang', 'Battambang'),
  ];
  const propByType = {
    ValuationType.land: 'Land',
    ValuationType.building: 'Villa',
  };
  const statuses = ValuationStatus.values;
  const purposes = ValuationPurpose.values;

  return List.generate(15, (i) {
    final type =
        i.isEven ? ValuationType.building : ValuationType.land;
    final status = statuses[i % statuses.length];
    final place = places[i % places.length];
    final hasValue = status == ValuationStatus.approved ||
        status == ValuationStatus.completed;
    final base = 60000 + i * 14500;
    return Valuation(
      id: 'v${i + 4}',
      refNo: 'VL-2026-${(540 + i * 13).toString().padLeft(4, '0')}',
      type: type,
      status: status,
      address: place.$1,
      province: place.$2,
      applicantName: names[i % names.length],
      purpose: purposes[i % purposes.length],
      propertyType: propByType[type]!,
      contactInfo: '+855 1${i % 9} 234 567',
      submittedDate: DateTime(2026, 6, 1).subtract(Duration(days: i * 3)),
      landSize: type == ValuationType.land ? '${300 + i * 20}' : null,
      buildingSize: type == ValuationType.building ? '${90 + i * 8}' : null,
      beds: type == ValuationType.building ? 2 + (i % 4) : null,
      baths: type == ValuationType.building ? 1 + (i % 3) : null,
      estimatedValue: hasValue ? base : null,
      valueLow: hasValue ? (base * 0.94).round() : null,
      valueHigh: hasValue ? (base * 1.06).round() : null,
    );
  });
}

/// Live store of the user's valuation requests (seeded with the mock history).
/// Newly submitted requests are inserted here so the hub reflects them.
class ValuationStore extends ChangeNotifier {
  final List<Valuation> _items = [...mockValuations];

  List<Valuation> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;

  void add(Valuation v) {
    _items.insert(0, v);
    notifyListeners();
  }
}

final valuationStore = ValuationStore();
