import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/utils/format.dart';
import '../../shared/widgets/module_hero_sliver.dart';
// Shared building blocks that still live with the Invest module.
import '../invest/widgets/invest_sheets.dart' show investToast;
import '../invest/widgets/invest_widgets.dart' show SectionTitle;
import 'data/loan.dart';
import 'widgets/loan_sheets.dart';

/// Standalone home-loan calculator + bank comparison. Promoted out of the
/// Invest module into its own top-level feature; all state is local.
class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final _amountCtrl = TextEditingController(text: '120,000');
  double _amount = 120000;
  int _years = 15;
  int _bankIndex = 0;

  BankLoan get _bank => mockBanks[_bankIndex];

  double get _monthly => monthlyRepayment(
        principal: _amount,
        annualRatePct: _bank.annualRate,
        years: _years,
      );

  double get _totalPayable => _monthly * _years * 12;

  void _onTyped(String v) {
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = (int.tryParse(digits) ?? 0).clamp(0, kLoanMax).toDouble();
    setState(() => _amount = parsed);
  }

  void _onSlider(double v) {
    setState(() => _amount = v);
    final formatted = _grouped(v.round());
    _amountCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canApply = _amount >= kLoanMin;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const ModuleHeroSliver(
            title: 'Loan',
            headline: 'Find the right home loan',
            subtitle:
                'Estimate your monthly repayment and compare offers from local banks.',
            icon: 'assets/icons/base/dollar_square.svg',
          ),
          ModuleHeroSheet(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
            child: Column(
              children: [
                _CalculatorCard(
                  amountCtrl: _amountCtrl,
                  amount: _amount,
                  years: _years,
                  monthly: _monthly,
                  totalPayable: _totalPayable,
                  rate: _bank.annualRate,
                  onTyped: _onTyped,
                  onSlider: _onSlider,
                  onYears: (v) => setState(() => _years = v),
                ),
                const SizedBox(height: 22),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SectionTitle('Compare local banks'),
                ),
                const SizedBox(height: 6),
                for (var i = 0; i < mockBanks.length; i++)
                  _BankRow(
                    bank: mockBanks[i],
                    selected: i == _bankIndex,
                    monthly: monthlyRepayment(
                      principal: _amount,
                      annualRatePct: mockBanks[i].annualRate,
                      years: _years,
                    ),
                    onTap: () => setState(() => _bankIndex = i),
                  ),
                const SizedBox(height: 20),
                _GoldButton(
                  label: canApply
                      ? 'Apply with ${_bank.name}'
                      : 'Enter ${usd(kLoanMin)}+',
                  onTap: () {
                    if (!canApply) {
                      investToast(context, 'Minimum loan is ${usd(kLoanMin)}');
                      return;
                    }
                    runLoanApply(
                      context,
                      bank: _bank,
                      amount: _amount.round(),
                      years: _years,
                      monthly: _monthly,
                    );
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Indicative only · final terms set by the bank',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({
    required this.amountCtrl,
    required this.amount,
    required this.years,
    required this.monthly,
    required this.totalPayable,
    required this.rate,
    required this.onTyped,
    required this.onSlider,
    required this.onYears,
  });

  final TextEditingController amountCtrl;
  final double amount;
  final int years;
  final double monthly;
  final double totalPayable;
  final double rate;
  final ValueChanged<String> onTyped;
  final ValueChanged<double> onSlider;
  final ValueChanged<int> onYears;

  static const _tenures = [5, 10, 15, 20, 25, 30];
  static const _capStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Result hero ──────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            gradient: AppColors.navyDepth,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Estimated monthly repayment',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    usd(monthly),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/mo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                        label: 'Total payable', value: usd(totalPayable)),
                  ),
                  _heroDivider(),
                  Expanded(
                      child: _HeroStat(label: 'Term', value: '$years yrs')),
                  _heroDivider(),
                  Expanded(
                    child: _HeroStat(
                        label: 'Interest',
                        value: '${rate.toStringAsFixed(1)}%'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Controls ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan amount
              Row(
                children: [
                  const Text(
                    'Loan amount',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'USD',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(7),
                          _ThousandsInputFormatter(),
                        ],
                        onChanged: onTyped,
                        cursorColor: AppColors.gold,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          filled: false,
                          border: InputBorder.none,
                          hintText: '0',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ThinSlider(
                value: amount.clamp(kLoanMin.toDouble(), kLoanMax.toDouble()),
                min: kLoanMin.toDouble(),
                max: kLoanMax.toDouble(),
                onChanged: onSlider,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(usd(kLoanMin), style: _capStyle),
                    Text(usd(kLoanMax), style: _capStyle),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tenure
              Row(
                children: [
                  const Text(
                    'Tenure',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$years years',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final t in _tenures) ...[
                    Expanded(
                      child: _TenureChip(
                        years: t,
                        selected: t == years,
                        onTap: () => onYears(t),
                      ),
                    ),
                    if (t != _tenures.last) const SizedBox(width: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _heroDivider() => Container(
        width: 1,
        height: 26,
        color: Colors.white.withValues(alpha: 0.12),
      );
}

/// One labelled stat inside the loan result hero.
class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Quick-select tenure chip (common mortgage terms).
class _TenureChip extends StatelessWidget {
  const _TenureChip({
    required this.years,
    required this.selected,
    required this.onTap,
  });

  final int years;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.border,
          ),
        ),
        child: Text(
          '${years}y',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// `1234567` → `1,234,567` for an integer.
String _grouped(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// Live thousands-grouping for the loan-amount text field.
class _ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final formatted = _grouped(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ThinSlider extends StatelessWidget {
  const _ThinSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        activeTrackColor: AppColors.gold,
        inactiveTrackColor: AppColors.iconTile,
        thumbColor: AppColors.gold,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({
    required this.bank,
    required this.selected,
    required this.monthly,
    required this.onTap,
  });

  final BankLoan bank;
  final bool selected;
  final double monthly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.gold : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(bank.logo, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${bank.annualRate.toStringAsFixed(1)}% p.a. · up to ${bank.maxTenureYears}y · ${bank.maxLtv}% LTV',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  usd(monthly),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const Text(
                  '/month',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width gold CTA (mirrors the Invest module's button).
class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.15,
          ),
        ),
      ),
    );
  }
}
