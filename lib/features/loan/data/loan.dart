// Local bank loan products + mortgage maths. Self-contained: the loan calculator
// keeps all of its state locally, so there is no store here (unlike `invest.dart`).

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
