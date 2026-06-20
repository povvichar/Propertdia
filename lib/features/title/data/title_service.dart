import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// Re-export shared formatters so screens importing this data file keep usd()/shortDate().
export '../../../shared/utils/format.dart';

enum TitleServiceType { verification, transfer, ownership, conversion }

/// Cambodian government property-transfer tax (stamp duty), levied on the
/// property value when a registered (hard/LMAP) title changes hands.
const kTransferTaxRate = 0.04;

enum TitleStatus { requested, inReview, approved, rejected, completed }

enum ContactWay { telegram, phone }

extension TitleServiceTypeX on TitleServiceType {
  String get label => switch (this) {
        TitleServiceType.verification => 'Title Verification',
        TitleServiceType.transfer => 'Title Transfer',
        TitleServiceType.ownership => 'Ownership Confirmation',
        TitleServiceType.conversion => 'Soft-to-Hard Conversion',
      };

  String get short => switch (this) {
        TitleServiceType.verification => 'Verification',
        TitleServiceType.transfer => 'Transfer',
        TitleServiceType.ownership => 'Ownership',
        TitleServiceType.conversion => 'Conversion',
      };

  String get blurb => switch (this) {
        TitleServiceType.verification =>
          'Check authenticity & encumbrances at the cadastral registry.',
        TitleServiceType.transfer =>
          'Transfer ownership between seller and buyer. 4% transfer tax on value calculated separately.',
        TitleServiceType.ownership =>
          'Obtain an official confirmation of the legal owner.',
        TitleServiceType.conversion =>
          'Upgrade a soft (commune-level) title to a registered hard title.',
      };

  String get asset => switch (this) {
        TitleServiceType.verification => 'assets/icons/base/certificate.svg',
        TitleServiceType.transfer => 'assets/icons/base/group_profile.svg',
        TitleServiceType.ownership => 'assets/icons/base/shield_user.svg',
        TitleServiceType.conversion => 'assets/icons/base/certificate.svg',
      };

  /// Government service fee, USD.
  int get fee => switch (this) {
        TitleServiceType.verification => 39,
        TitleServiceType.transfer => 149,
        TitleServiceType.ownership => 59,
        TitleServiceType.conversion => 199,
      };

  /// Estimated processing time in working days.
  int get workingDays => switch (this) {
        TitleServiceType.verification => 5,
        TitleServiceType.transfer => 15,
        TitleServiceType.ownership => 10,
        TitleServiceType.conversion => 30,
      };

  /// Documents the applicant must upload for this service.
  List<String> get requiredDocs => switch (this) {
        TitleServiceType.verification => const [
            'Title certificate (front & back)',
            'Owner ID card',
          ],
        TitleServiceType.transfer => const [
            'Title certificate',
            'Seller & buyer ID cards',
            'Sale–purchase agreement',
            'Spouse consent letter (if married)',
            'Tax clearance letter',
          ],
        TitleServiceType.ownership => const [
            'Title certificate',
            'Owner ID card',
            'Family / residence book',
          ],
        TitleServiceType.conversion => const [
            'Soft title / commune certificate',
            'Owner ID card',
            'Family / residence book',
            'Village & commune chief attestation',
          ],
      };

  /// Fuller, plain-language explanation shown in the service info sheet.
  String get detail => switch (this) {
        TitleServiceType.verification =>
          'We pull the official cadastral record for your property and '
              'cross-check it against the certificate to confirm the title is '
              'genuine, identify the true registered owner, and reveal any '
              'mortgages, liens, court injunctions or overlapping claims — so '
              'you know exactly what you are buying or lending against.',
        TitleServiceType.transfer =>
          'We handle the full ownership transfer between seller and buyer at '
              'the Cadastral Administration: preparing the sale documents, '
              'calculating and settling the 4% government transfer tax (stamp '
              'duty) on the declared value, and re-registering the hard / LMAP '
              'title in the new owner’s name.',
        TitleServiceType.ownership =>
          'We obtain an official confirmation from the registry stating who '
              'legally owns the property — useful for legal proceedings, '
              'inheritance, bank financing, or simply proving ownership when '
              'the original holder is unavailable.',
        TitleServiceType.conversion =>
          'We upgrade a soft (commune-level) title into a fully registered '
              'hard title: gathering the local attestations, surveying and '
              'demarcating the land, and lodging the systematic-registration '
              'application so your ownership is recognised nationally and '
              'becomes mortgageable and freely transferable.',
      };

  /// Ordered "how it works" steps shown in the service info sheet.
  List<String> get steps => switch (this) {
        TitleServiceType.verification => const [
            'Submit the title certificate and owner ID',
            'Our agent files a search at the Cadastral Administration',
            'Record is checked for authenticity & encumbrances',
            'You receive a verification report with the findings',
          ],
        TitleServiceType.transfer => const [
            'Prepare and verify the sale–purchase agreement',
            'Settle the 4% transfer tax on the declared value',
            'Lodge the transfer at the Cadastral Administration',
            'Collect the re-issued title in the new owner’s name',
          ],
        TitleServiceType.ownership => const [
            'Submit the title and owner identification',
            'We request an ownership extract from the registry',
            'Registry confirms the legal owner of record',
            'You receive an official ownership confirmation',
          ],
        TitleServiceType.conversion => const [
            'Collect commune certificate & chief attestations',
            'Land is surveyed and boundaries demarcated',
            'Application lodged for systematic registration',
            'Hard title issued and registered nationally',
          ],
      };
}

extension TitleStatusX on TitleStatus {
  String get label => switch (this) {
        TitleStatus.requested => 'Requested',
        TitleStatus.inReview => 'In Review',
        TitleStatus.approved => 'Approved',
        TitleStatus.rejected => 'Rejected',
        TitleStatus.completed => 'Completed',
      };

  Color get color => switch (this) {
        TitleStatus.requested => AppColors.info,
        TitleStatus.inReview => AppColors.warning,
        TitleStatus.approved => AppColors.success,
        TitleStatus.rejected => AppColors.danger,
        TitleStatus.completed => AppColors.success,
      };

  int get step => switch (this) {
        TitleStatus.requested => 0,
        TitleStatus.inReview => 1,
        TitleStatus.approved => 2,
        TitleStatus.rejected => 2,
        TitleStatus.completed => 3,
      };
}

class TitleApplication {
  const TitleApplication({
    required this.id,
    required this.refNo,
    required this.type,
    required this.status,
    required this.titleType,
    required this.address,
    this.province = '',
    required this.applicantName,
    required this.contactWay,
    required this.contactInfo,
    required this.submittedDate,
    required this.documents,
    this.transferTo,
    this.propertyValue,
  });

  final String id;
  final String refNo;
  final TitleServiceType type;
  final TitleStatus status;
  final String titleType; // Hard / Soft / LMAP
  final String address;
  final String province;
  final String applicantName;
  final ContactWay contactWay;
  final String contactInfo;
  final DateTime submittedDate;
  final List<String> documents;
  final String? transferTo;

  /// Declared property value (USD) — drives the 4% transfer-tax estimate.
  final int? propertyValue;

  /// Government transfer tax (stamp duty) on the declared value, or null if no
  /// value was provided.
  int? get transferTax =>
      propertyValue == null ? null : (propertyValue! * kTransferTaxRate).round();
}

/// Adds [days] to [from] skipping weekends (approx. working days).
DateTime addWorkingDays(DateTime from, int days) {
  var d = from;
  var added = 0;
  while (added < days) {
    d = d.add(const Duration(days: 1));
    if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
      added++;
    }
  }
  return d;
}

const kTitleTypes = ['Hard Title', 'Soft Title', 'LMAP Title', 'Strata Title'];

/// Existing applications shown on the hub for status tracking.
final mockTitleApplications = <TitleApplication>[
  TitleApplication(
    id: 't1',
    refNo: 'TS-2026-0307',
    type: TitleServiceType.transfer,
    status: TitleStatus.completed,
    titleType: 'Hard Title',
    address: 'No. 27, Street 360, BKK1',
    province: 'Phnom Penh',
    applicantName: 'Chan Rithy',
    contactWay: ContactWay.telegram,
    contactInfo: '@chanrithy',
    submittedDate: DateTime(2026, 5, 20),
    documents: [
      'Title certificate',
      'Seller & buyer ID cards',
      'Sale–purchase agreement',
    ],
    transferTo: 'Sok Dara',
  ),
  TitleApplication(
    id: 't2',
    refNo: 'TS-2026-0455',
    type: TitleServiceType.verification,
    status: TitleStatus.inReview,
    titleType: 'Soft Title',
    address: 'Wat Bo Road, Sangkat Sala Kamreuk',
    province: 'Siem Reap',
    applicantName: 'Sophea Lim',
    contactWay: ContactWay.phone,
    contactInfo: '+855 12 345 678',
    submittedDate: DateTime(2026, 6, 8),
    documents: ['Title certificate (front & back)', 'Owner ID card'],
  ),
  TitleApplication(
    id: 't3',
    refNo: 'TS-2026-0492',
    type: TitleServiceType.ownership,
    status: TitleStatus.requested,
    titleType: 'LMAP Title',
    address: 'Krong Battambang, Sangkat Svay Por',
    province: 'Battambang',
    applicantName: 'Dara Kim',
    contactWay: ContactWay.telegram,
    contactInfo: '@darakim',
    submittedDate: DateTime(2026, 6, 11),
    documents: [
      'Title certificate',
      'Owner ID card',
      'Family / residence book',
    ],
  ),
  ..._generatedTitleApplications(),
];

/// Extra demo applications so the hub list exercises filtering/scroll at volume.
/// Cycles types & statuses so every status filter has several matches.
List<TitleApplication> _generatedTitleApplications() {
  const names = [
    'Vannak Chea', 'Bopha Sok', 'Rithy Pen', 'Sreymom Kong', 'Sovann Meas',
    'Pisey Heng', 'Kosal Ny', 'Channary Va', 'Veasna Tep', 'Dalin Sam',
    'Makara Yon', 'Sothea Lim', 'Phalla Roeun', 'Visal Oeur', 'Sokha Chan',
    'Theary Khun', 'Nimol Sok',
  ];
  const places = <(String, String)>[
    ('Street 271, Sangkat Tomnop Teuk', 'Phnom Penh'),
    ('National Road 6, Svay Dangkum', 'Siem Reap'),
    ('Sangkat 4, Mittapheap', 'Preah Sihanouk'),
    ('Krong Doun Kaev, Sangkat Roka Knong', 'Takeo'),
    ('Sangkat Kampong Cham, Krong Kampong Cham', 'Kampong Cham'),
    ('Ou Ambel, Krong Serei Saophoan', 'Banteay Meanchey'),
    ('Sangkat Svay Por, Krong Battambang', 'Battambang'),
    ('Phsar Kandal, Daun Penh', 'Phnom Penh'),
  ];
  const types = TitleServiceType.values;
  const statuses = TitleStatus.values;

  return List.generate(17, (i) {
    final type = types[i % types.length];
    final status = statuses[i % statuses.length];
    final place = places[i % places.length];
    final isTransfer = type == TitleServiceType.transfer;
    return TitleApplication(
      id: 't${i + 4}',
      refNo: 'TS-2026-${(500 + i * 13).toString().padLeft(4, '0')}',
      type: type,
      status: status,
      titleType: kTitleTypes[i % kTitleTypes.length],
      address: place.$1,
      province: place.$2,
      applicantName: names[i % names.length],
      contactWay: i.isEven ? ContactWay.telegram : ContactWay.phone,
      contactInfo:
          i.isEven ? '@${names[i % names.length].split(' ').first.toLowerCase()}' : '+855 1${(i % 9)} 234 567',
      submittedDate: DateTime(2026, 6, 1).subtract(Duration(days: i * 3)),
      documents: type.requiredDocs,
      transferTo: isTransfer ? 'Buyer ${i + 1}' : null,
      propertyValue: isTransfer ? 80000 + i * 5000 : null,
    );
  });
}

/// Live store of the user's title applications (seeded with the mock history).
/// Newly submitted applications are inserted here so the hub reflects them.
class TitleStore extends ChangeNotifier {
  final List<TitleApplication> _items = [...mockTitleApplications];

  List<TitleApplication> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;

  void add(TitleApplication a) {
    _items.insert(0, a);
    notifyListeners();
  }
}

final titleStore = TitleStore();
