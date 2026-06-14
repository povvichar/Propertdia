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

// ── Live investor state (singleton ChangeNotifier, mirrors savedForceSale) ────

enum MembershipStatus { none, pending, active }

/// Simulated admin processing time (review of membership / deposit).
const _adminReview = Duration(seconds: 4);

class InvestStore extends ChangeNotifier {
  MembershipStatus _membership = MembershipStatus.none;
  int _balance = 0;
  final List<WalletTxn> _txns = [];
  final List<Holding> _holdings = [];

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

  // ── Session ────────────────────────────────────────────────────────────
  void signInNormal() {
    _membership = MembershipStatus.none;
    _balance = 0;
    _txns.clear();
    _holdings.clear();
    notifyListeners();
  }

  void signInInvestor() {
    _membership = MembershipStatus.active;
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

  // ── Membership: request → admin review → approved ──────────────────────
  void requestMembership() {
    if (_membership != MembershipStatus.none) return;
    _membership = MembershipStatus.pending;
    notifyListeners();
    Future.delayed(_adminReview, () {
      if (_membership == MembershipStatus.pending) {
        _membership = MembershipStatus.active;
        notifyListeners();
      }
    });
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
    dividends: [],
  ),
];
