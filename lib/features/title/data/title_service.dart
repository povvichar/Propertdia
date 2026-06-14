import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

// Re-export shared formatters so screens importing this data file keep usd()/shortDate().
export '../../../shared/utils/format.dart';

enum TitleServiceType { verification, transfer, ownership }

enum TitleStatus { requested, inReview, approved, rejected, completed }

enum ContactWay { telegram, phone }

extension TitleServiceTypeX on TitleServiceType {
  String get label => switch (this) {
        TitleServiceType.verification => 'Title Verification',
        TitleServiceType.transfer => 'Title Transfer',
        TitleServiceType.ownership => 'Ownership Confirmation',
      };

  String get short => switch (this) {
        TitleServiceType.verification => 'Verification',
        TitleServiceType.transfer => 'Transfer',
        TitleServiceType.ownership => 'Ownership',
      };

  String get blurb => switch (this) {
        TitleServiceType.verification =>
          'Check authenticity & encumbrances at the cadastral registry.',
        TitleServiceType.transfer =>
          'Transfer ownership between seller and buyer, incl. transfer tax.',
        TitleServiceType.ownership =>
          'Obtain an official confirmation of the legal owner.',
      };

  String get asset => switch (this) {
        TitleServiceType.verification => 'assets/icons/base/certificate.svg',
        TitleServiceType.transfer => 'assets/icons/base/group_profile.svg',
        TitleServiceType.ownership => 'assets/icons/base/shield_user.svg',
      };

  /// Government service fee, USD.
  int get fee => switch (this) {
        TitleServiceType.verification => 39,
        TitleServiceType.transfer => 149,
        TitleServiceType.ownership => 59,
      };

  /// Estimated processing time in working days.
  int get workingDays => switch (this) {
        TitleServiceType.verification => 5,
        TitleServiceType.transfer => 15,
        TitleServiceType.ownership => 10,
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
          ],
        TitleServiceType.ownership => const [
            'Title certificate',
            'Owner ID card',
            'Family / residence book',
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

const kTitleTypes = ['Hard Title', 'Soft Title', 'LMAP Title'];

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
];
