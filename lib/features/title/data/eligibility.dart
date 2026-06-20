import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Who is acquiring the property.
enum Nationality { cambodian, foreign }

/// What is being acquired — the distinction that drives Cambodian
/// foreign-ownership rules (land vs. a strata unit in a co-owned building).
enum AcquiringKind { land, landedHouse, strataUnit }

enum EligibilityVerdict { eligible, conditional, notDirect }

extension AcquiringKindX on AcquiringKind {
  String get label => switch (this) {
        AcquiringKind.land => 'Land (vacant plot)',
        AcquiringKind.landedHouse => 'House with land',
        AcquiringKind.strataUnit => 'Condo / strata unit',
      };
}

extension EligibilityVerdictX on EligibilityVerdict {
  String get label => switch (this) {
        EligibilityVerdict.eligible => 'Eligible',
        EligibilityVerdict.conditional => 'Conditional',
        EligibilityVerdict.notDirect => 'Not directly',
      };

  Color get color => switch (this) {
        EligibilityVerdict.eligible => AppColors.success,
        EligibilityVerdict.conditional => AppColors.gold,
        EligibilityVerdict.notDirect => AppColors.danger,
      };
}

/// Outcome of the ownership-eligibility check.
class EligibilityResult {
  const EligibilityResult({
    required this.verdict,
    required this.headline,
    required this.points,
    this.note,
  });

  final EligibilityVerdict verdict;
  final String headline;
  final List<String> points;
  final String? note;
}

/// Deterministic ownership-eligibility guidance under Cambodian property law.
///
/// Key rules: foreigners cannot own land (2010 Law on Foreign Ownership);
/// they may own strata units above the ground floor, capped at 70% of a
/// co-owned building. Cambodian nationals may hold any title type.
EligibilityResult checkEligibility({
  required Nationality who,
  required AcquiringKind kind,
  bool groundFloor = false,
}) {
  if (who == Nationality.cambodian) {
    return const EligibilityResult(
      verdict: EligibilityVerdict.eligible,
      headline: 'You can hold full ownership',
      points: [
        'Cambodian nationals may own land and buildings outright.',
        'Eligible for a Hard Title (or LMAP systematic-registration title).',
        'A strata unit is held under a Strata Title.',
      ],
    );
  }

  // Foreign nationals.
  switch (kind) {
    case AcquiringKind.strataUnit:
      if (groundFloor) {
        return const EligibilityResult(
          verdict: EligibilityVerdict.notDirect,
          headline: 'Ground-floor units are not available to foreigners',
          points: [
            'Foreigners may own strata units, but NOT the ground floor or basement.',
            'Choose a unit on the 1st floor or above.',
            'A long-term lease can be an alternative for a ground-floor unit.',
          ],
          note: 'Ground floor is reserved for Cambodian co-owners.',
        );
      }
      return const EligibilityResult(
        verdict: EligibilityVerdict.conditional,
        headline: 'Eligible — strata unit (with conditions)',
        points: [
          'Foreigners may own a strata unit above the ground floor.',
          'Held under a Strata Title in your own name.',
          'Subject to the 70% foreign-ownership cap per building.',
        ],
        note: 'Confirm the building has not reached its 70% foreign quota.',
      );
    case AcquiringKind.land:
    case AcquiringKind.landedHouse:
      return const EligibilityResult(
        verdict: EligibilityVerdict.notDirect,
        headline: 'Foreigners cannot own land directly',
        points: [
          'A strata unit (condo above ground floor) — owned in your name.',
          'A long-term lease, up to 50 years and renewable.',
          'A Cambodian-majority landholding company (≥51% Cambodian).',
          'A nominee structure — common but legally risky; get advice.',
        ],
        note: 'Land ownership is restricted to Cambodian nationals.',
      );
  }
}
