import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/format.dart';

// Re-export shared formatters so screens importing this data file keep usd()/fmtDate().
export '../../../shared/utils/format.dart';

// ── Investment projects ──────────────────────────────────────────────────────

enum ProjectType { borey, landSplit }

extension ProjectTypeX on ProjectType {
  String get label => switch (this) {
        ProjectType.borey => 'Borey Project',
        ProjectType.landSplit => 'Land Split',
      };

  Color get color => switch (this) {
        ProjectType.borey => AppColors.navy,
        ProjectType.landSplit => AppColors.success,
      };
}

class InvestProject {
  const InvestProject({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.targetRoi,
    required this.termMonths,
    required this.minInvest,
    required this.raised,
    required this.goal,
    required this.imageUrl,
    required this.summary,
    this.dividends = const [],
    this.minTier = InvestorTier.silver,
  });

  final String id;
  final String name;
  final String location;
  final ProjectType type;
  final double targetRoi; // annual %
  final int termMonths;
  final int minInvest;
  final int raised;
  final int goal;
  final String imageUrl;
  final String summary;
  final List<DividendRecord> dividends;

  /// Minimum tier required to invest (early / priority access perk).
  final InvestorTier minTier;

  double get fundedPct => goal <= 0 ? 0 : (raised / goal).clamp(0, 1);

  /// Projected value of [amount] at maturity using the target ROI.
  int projectedReturn(int amount) =>
      (amount * (1 + targetRoi / 100 * termMonths / 12)).round();
}

class DividendRecord {
  const DividendRecord({
    required this.date,
    required this.amount,
    required this.note,
  });

  final String date;
  final int amount;
  final String note;
}

// ── Membership benefits ──────────────────────────────────────────────────────

class InvestorBenefit {
  const InvestorBenefit(this.icon, this.title, this.blurb);
  final String icon;
  final String title;
  final String blurb;
}

const investorBenefits = <InvestorBenefit>[
  InvestorBenefit(
    'assets/icons/base/clock.svg',
    'Early Access',
    'Be the first to see and invest in new land split and Borey projects.',
  ),
  InvestorBenefit(
    'assets/icons/base/earning.svg',
    'High-Yield ROI',
    'Targeted annual returns of 12% – 18% on selected developments.',
  ),
  InvestorBenefit(
    'assets/icons/base/shield.svg',
    'Risk Mitigation',
    'Every project is pre-vetted by our legal and valuation experts.',
  ),
];

// ── Project trust: legal protections + documents ─────────────────────────────

class ProjectProtection {
  const ProjectProtection(this.icon, this.title, this.blurb);
  final String icon;
  final String title;
  final String blurb;
}

/// Platform-level safeguards shown on every project detail to build trust.
const kProjectProtections = <ProjectProtection>[
  ProjectProtection(
    'assets/icons/base/certificate.svg',
    'Hard title secured',
    'The land holds a government-issued hard title, verified against the '
        'cadastral registry.',
  ),
  ProjectProtection(
    'assets/icons/base/shield.svg',
    'Escrow-protected funds',
    'Capital is held in escrow and released to the developer only against '
        'verified construction milestones.',
  ),
  ProjectProtection(
    'assets/icons/base/approve.svg',
    'Independently vetted',
    'Pre-screened by our in-house legal and valuation experts before listing.',
  ),
  ProjectProtection(
    'assets/icons/base/document.svg',
    'Registered agreement',
    'You receive a registered investment contract defining your share and '
        'payout schedule.',
  ),
];

class ProjectDoc {
  const ProjectDoc(this.name, this.size);
  final String name;
  final String size; // human-readable file size for the demo
}

/// Documents made available for due diligence on each project.
const kProjectDocs = <ProjectDoc>[
  ProjectDoc('Investment prospectus', '2.4 MB'),
  ProjectDoc('Hard title certificate', '1.1 MB'),
  ProjectDoc('Independent valuation report', '3.2 MB'),
  ProjectDoc('Investment agreement', '0.6 MB'),
];

/// Extra gallery shots shown alongside each project's hero image.
const kGalleryExtras = <String>[
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=900&q=80',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=900&q=80',
  'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=900&q=80',
  'https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=900&q=80',
];

// ── Contact ───────────────────────────────────────────────────────────────────

const kAdvisorTelegram = '@propertdia_invest';
const kAdvisorPhone = '+855 23 900 100';

// ── Wallet transactions ──────────────────────────────────────────────────────

enum TxnKind { deposit, withdrawal, dividend, settlement }

extension TxnKindX on TxnKind {
  String get label => switch (this) {
        TxnKind.deposit => 'Deposit',
        TxnKind.withdrawal => 'Withdrawal',
        TxnKind.dividend => 'Dividend',
        TxnKind.settlement => 'Investment',
      };

  String get icon => switch (this) {
        TxnKind.deposit => 'assets/icons/base/arrowdownleft.svg',
        TxnKind.withdrawal => 'assets/icons/base/arrowupright.svg',
        TxnKind.dividend => 'assets/icons/base/earning.svg',
        TxnKind.settlement => 'assets/icons/base/suitcase.svg',
      };

  bool get isCredit => this == TxnKind.deposit || this == TxnKind.dividend;
}

enum TxnStatus { pending, completed }

class WalletTxn {
  WalletTxn({
    required this.kind,
    required this.title,
    required this.date,
    required this.amount, // always positive; sign derived from kind
    this.method = '',
    this.status = TxnStatus.completed,
  });

  final TxnKind kind;
  final String title;
  final String date;
  final int amount;
  final String method;
  TxnStatus status;

  bool get isPending => status == TxnStatus.pending;
  int get signed => kind.isCredit ? amount : -amount;
}

// ── A holding the user owns ──────────────────────────────────────────────────

class Holding {
  Holding({required this.project, required this.amount, required this.date});

  final InvestProject project;
  int amount;
  final DateTime date;
}

// ── Deposit / withdraw methods (local rails) ─────────────────────────────────

class PayMethod {
  const PayMethod(this.name, this.logo);
  final String name;
  final String logo;
}

const payMethods = <PayMethod>[
  PayMethod('ABA Bank', 'assets/icons/base/aba.svg'),
  PayMethod('ACLEDA', 'assets/icons/base/acleda.svg'),
  PayMethod('Wing', 'assets/icons/base/wing.svg'),
];

// ── Investor tiers (Silver → Gold → Platinum) ────────────────────────────────

enum InvestorTier { silver, gold, platinum }

/// Shared USD thresholds: a member reaches Gold at $50k and Platinum at $250k —
/// applied both to application criteria (starting tier) and cumulative invested
/// amount (activity auto-promotion).
const kGoldThreshold = 50000;
const kPlatinumThreshold = 250000;

/// Effectively-unlimited per-deal cap for the top tier.
const _unlimited = 1 << 30;

InvestorTier tierForValue(int v) => v >= kPlatinumThreshold
    ? InvestorTier.platinum
    : v >= kGoldThreshold
        ? InvestorTier.gold
        : InvestorTier.silver;

extension InvestorTierX on InvestorTier {
  String get label => switch (this) {
        InvestorTier.silver => 'Silver',
        InvestorTier.gold => 'Gold',
        InvestorTier.platinum => 'Platinum',
      };

  Color get color => switch (this) {
        InvestorTier.silver => AppColors.silver,
        InvestorTier.gold => AppColors.gold,
        InvestorTier.platinum => AppColors.platinum,
      };

  Color get colorSoft => switch (this) {
        InvestorTier.silver => AppColors.silverSoft,
        InvestorTier.gold => AppColors.goldSoft,
        InvestorTier.platinum => AppColors.platinumSoft,
      };

  /// Maximum amount investable in a single deal at this tier (perk).
  int get maxInvest => switch (this) {
        InvestorTier.silver => 25000,
        InvestorTier.gold => 100000,
        InvestorTier.platinum => _unlimited,
      };

  String get maxInvestLabel =>
      this == InvestorTier.platinum ? 'Unlimited' : usd(maxInvest);

  bool outranks(InvestorTier other) => index > other.index;
}

// Application criteria option bands (used by the application form + start tier).
const kIncomeBands = ['Under \$25k', '\$25k – \$100k', '\$100k+'];
const kAssetBands = ['Under \$50k', '\$50k – \$250k', '\$250k or more'];
const kExperienceLevels = ['First-time', 'Some experience', 'Experienced'];
const kFundSources = [
  'Salary',
  'Business income',
  'Savings',
  'Investment returns',
  'Other',
];

/// Maps the selected investable-assets band to the starting tier.
InvestorTier tierForAssetBand(String band) {
  final i = kAssetBands.indexOf(band);
  return i >= 2
      ? InvestorTier.platinum
      : i == 1
          ? InvestorTier.gold
          : InvestorTier.silver;
}

/// A submitted investor membership application (KYC-style criteria).
class InvestorApplication {
  InvestorApplication({
    required this.legalName,
    required this.idNumber,
    required this.annualIncome,
    required this.investableAssets,
    required this.experience,
    required this.sourceOfFunds,
    required this.intendedCommitment,
    required this.riskAccepted,
    required this.submittedAt,
  });

  final String legalName;
  final String idNumber;
  final String annualIncome;
  final String investableAssets; // drives the starting tier
  final String experience;
  final String sourceOfFunds;
  final int intendedCommitment;
  final bool riskAccepted;
  final DateTime submittedAt;
}

// ── Live investor state (singleton ChangeNotifier, mirrors savedForceSale) ────

enum MembershipStatus { none, pending, active }

/// Simulated admin processing time (review of membership / deposit).
const _adminReview = Duration(seconds: 4);

class InvestStore extends ChangeNotifier {
  MembershipStatus _membership = MembershipStatus.none;
  int _balance = 0;
  final List<WalletTxn> _txns = [];
  final List<Holding> _holdings = [];
  InvestorApplication? _application;
  InvestorTier _startTier = InvestorTier.silver;

  MembershipStatus get membership => _membership;
  bool get isInvestor => _membership == MembershipStatus.active;
  bool get isPendingReview => _membership == MembershipStatus.pending;
  int get balance => _balance;
  List<WalletTxn> get transactions => List.unmodifiable(_txns);
  List<Holding> get holdings => List.unmodifiable(_holdings);
  bool get hasPendingDeposit => _txns.any((t) => t.isPending);

  // Portfolio analytics — derived from real holdings the user creates.
  int get totalInvested => _holdings.fold(0, (s, h) => s + h.amount);
  int get activeDeals => _holdings.map((h) => h.project.id).toSet().length;
  int get projectedValue =>
      _holdings.fold(0, (s, h) => s + h.project.projectedReturn(h.amount));
  int get projectedGain => projectedValue - totalInvested;
  double get blendedRoi {
    final tot = totalInvested;
    if (tot == 0) return 0;
    final weighted =
        _holdings.fold<double>(0, (s, h) => s + h.project.targetRoi * h.amount);
    return weighted / tot;
  }

  int investedIn(String projectId) => _holdings
      .where((h) => h.project.id == projectId)
      .fold(0, (s, h) => s + h.amount);

  // ── Tier (hybrid: starting tier from criteria, then activity-promoted) ──
  InvestorApplication? get application => _application;

  /// Effective rank — the higher of the application starting tier and the tier
  /// earned through cumulative invested amount.
  InvestorTier get tier {
    final activity = tierForValue(totalInvested);
    return activity.outranks(_startTier) ? activity : _startTier;
  }

  int get tierMaxInvest => tier.maxInvest;

  InvestorTier? get nextTier => switch (tier) {
        InvestorTier.silver => InvestorTier.gold,
        InvestorTier.gold => InvestorTier.platinum,
        InvestorTier.platinum => null,
      };

  /// Cumulative-invested amount at which the next tier unlocks.
  int get nextTierAt => switch (tier) {
        InvestorTier.silver => kGoldThreshold,
        InvestorTier.gold => kPlatinumThreshold,
        InvestorTier.platinum => 0,
      };

  int get nextTierRemaining =>
      nextTier == null ? 0 : (nextTierAt - totalInvested).clamp(0, nextTierAt);

  double get tierProgress =>
      nextTier == null ? 1 : (totalInvested / nextTierAt).clamp(0.0, 1.0);

  bool canInvestIn(InvestProject p) => !p.minTier.outranks(tier);

  // ── Session ────────────────────────────────────────────────────────────
  void signInNormal() {
    _membership = MembershipStatus.none;
    _balance = 0;
    _txns.clear();
    _holdings.clear();
    _application = null;
    _startTier = InvestorTier.silver;
    notifyListeners();
  }

  void signInInvestor() {
    _membership = MembershipStatus.active;
    _application = null;
    _startTier = InvestorTier.gold; // seeded demo investor presents as Gold
    _balance = 13000;
    _holdings
      ..clear()
      ..add(Holding(
          project: mockProjects[0], amount: 7000, date: DateTime.now()));
    _txns
      ..clear()
      ..addAll([
        WalletTxn(
            kind: TxnKind.settlement,
            title: 'Invested · ${mockProjects[0].name}',
            date: '02 Jun 2026',
            amount: 7000),
        WalletTxn(
            kind: TxnKind.deposit,
            title: 'Top-up via ABA Bank',
            date: '28 May 2026',
            amount: 20000,
            method: 'ABA Bank'),
      ]);
    notifyListeners();
  }

  // ── Membership: apply → stays under review → admin approves ────────────
  void requestMembership(InvestorApplication app) {
    if (_membership != MembershipStatus.none) return;
    _application = app;
    _startTier = tierForAssetBand(app.investableAssets);
    _membership = MembershipStatus.pending;
    notifyListeners();
    // No auto-approval: the request stays under review until an admin
    // approves it (simulated via approveMembership / the long-press on the
    // pending card in the demo).
  }

  /// Simulate the admin approving a pending membership request. The new
  /// investor starts with an empty wallet — no seeded balance or holdings —
  /// and the starting tier derived from their application criteria.
  void approveMembership() {
    if (_membership != MembershipStatus.pending) return;
    _membership = MembershipStatus.active;
    notifyListeners();
  }

  // ── Deposit: submit payment → admin confirms → credited ────────────────
  void submitDeposit(int amount, String method) {
    if (amount <= 0) return;
    final txn = WalletTxn(
      kind: TxnKind.deposit,
      title: 'Top-up via $method',
      date: fmtDate(DateTime.now()),
      amount: amount,
      method: method,
      status: TxnStatus.pending,
    );
    _txns.insert(0, txn);
    notifyListeners();
    Future.delayed(_adminReview, () {
      txn.status = TxnStatus.completed;
      _balance += amount;
      notifyListeners();
    });
  }

  bool withdraw(int amount, String method) {
    if (amount <= 0 || amount > _balance) return false;
    _balance -= amount;
    _txns.insert(
      0,
      WalletTxn(
        kind: TxnKind.withdrawal,
        title: 'Withdraw to $method',
        date: fmtDate(DateTime.now()),
        amount: amount,
        method: method,
      ),
    );
    notifyListeners();
    return true;
  }

  bool invest(InvestProject project, int amount) {
    if (amount < project.minInvest || amount > _balance) return false;
    _balance -= amount;
    final i = _holdings.indexWhere((h) => h.project.id == project.id);
    if (i >= 0) {
      _holdings[i].amount += amount;
    } else {
      _holdings.insert(
        0,
        Holding(project: project, amount: amount, date: DateTime.now()),
      );
    }
    _txns.insert(
      0,
      WalletTxn(
        kind: TxnKind.settlement,
        title: 'Invested · ${project.name}',
        date: fmtDate(DateTime.now()),
        amount: amount,
      ),
    );
    notifyListeners();
    return true;
  }
}

final investStore = InvestStore();

// ── Local bank loan products ─────────────────────────────────────────────────

class BankLoan {
  const BankLoan({
    required this.name,
    required this.logo,
    required this.annualRate,
    required this.maxTenureYears,
    required this.maxLtv,
  });

  final String name;
  final String logo;
  final double annualRate; // % per year
  final int maxTenureYears;
  final int maxLtv; // % loan-to-value
}

const mockBanks = <BankLoan>[
  BankLoan(
    name: 'ABA Bank',
    logo: 'assets/icons/base/aba.svg',
    annualRate: 8.5,
    maxTenureYears: 25,
    maxLtv: 70,
  ),
  BankLoan(
    name: 'ACLEDA Bank',
    logo: 'assets/icons/base/acleda.svg',
    annualRate: 9.0,
    maxTenureYears: 20,
    maxLtv: 70,
  ),
  BankLoan(
    name: 'Wing Bank',
    logo: 'assets/icons/base/wing.svg',
    annualRate: 10.5,
    maxTenureYears: 15,
    maxLtv: 60,
  ),
];

const kLoanMin = 10000;
const kLoanMax = 1000000;

/// Standard amortized monthly repayment.
double monthlyRepayment({
  required double principal,
  required double annualRatePct,
  required int years,
}) {
  final n = years * 12;
  final r = annualRatePct / 100 / 12;
  if (r == 0) return principal / n;
  final f = _pow(1 + r, n);
  return principal * r * f / (f - 1);
}

double _pow(double base, int exp) {
  var result = 1.0;
  for (var i = 0; i < exp; i++) {
    result *= base;
  }
  return result;
}

// ── Mock projects ────────────────────────────────────────────────────────────

const mockProjects = <InvestProject>[
  InvestProject(
    id: 'p1',
    name: 'Borey Vimean — Phase 3',
    location: 'Chbar Ampov, Phnom Penh',
    type: ProjectType.borey,
    targetRoi: 15,
    termMonths: 18,
    minInvest: 5000,
    raised: 816000,
    goal: 1200000,
    imageUrl:
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=900&q=80',
    summary:
        'A gated Borey of 84 link-houses near the new Chbar Ampov bridge. '
        'Returns paid from staged unit hand-overs.',
    dividends: [
      DividendRecord(date: '12 Jun 2026', amount: 420, note: 'Q2 distribution'),
      DividendRecord(date: '12 Mar 2026', amount: 405, note: 'Q1 distribution'),
    ],
  ),
  InvestProject(
    id: 'p2',
    name: 'Chroy Changvar Riverside Land',
    location: 'Chroy Changvar, Phnom Penh',
    type: ProjectType.landSplit,
    targetRoi: 18,
    termMonths: 24,
    minInvest: 10000,
    raised: 1050000,
    goal: 2500000,
    imageUrl:
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&q=80',
    summary:
        'A 1.2-hectare riverfront plot subdivided into 30 titled lots. '
        'Exit on resale once hard titles are issued.',
    minTier: InvestorTier.gold,
    dividends: [
      DividendRecord(date: '20 May 2026', amount: 0, note: 'Reinvested'),
    ],
  ),
  InvestProject(
    id: 'p3',
    name: 'The Star — Sen Sok',
    location: 'Sen Sok, Phnom Penh',
    type: ProjectType.borey,
    targetRoi: 13,
    termMonths: 12,
    minInvest: 3000,
    raised: 680000,
    goal: 800000,
    imageUrl:
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=900&q=80',
    summary:
        'Final block of shophouses in an established Peng Huoth community. '
        'Short tenor with pre-sold units.',
    dividends: [
      DividendRecord(date: '10 May 2026', amount: 310, note: 'Q1 distribution'),
    ],
  ),
  InvestProject(
    id: 'p4',
    name: 'Kandal Stueng Subdivision',
    location: 'Kandal Stueng, Kandal',
    type: ProjectType.landSplit,
    targetRoi: 16,
    termMonths: 30,
    minInvest: 8000,
    raised: 540000,
    goal: 1800000,
    imageUrl:
        'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=900&q=80',
    summary:
        'Farmland conversion along NR2 near the new airport access road. '
        'Higher tenor, capital-growth play.',
    minTier: InvestorTier.platinum,
    dividends: [],
  ),
];
