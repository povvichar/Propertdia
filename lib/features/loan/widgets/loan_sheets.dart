import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/format.dart';
import '../../../shared/widgets/primary_button.dart';
// Shared sheet primitives still live with the Invest module.
import '../../invest/widgets/invest_sheets.dart' show SheetShell, investToast;
import '../data/loan.dart';

// ── Loan application flow ────────────────────────────────────────────────────

Future<void> runLoanApply(
  BuildContext context, {
  required BankLoan bank,
  required int amount,
  required int years,
  required double monthly,
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetTitle(
            'Apply with ${bank.name}',
            subtitle: 'Review your financing request before submitting.',
          ),
          const SizedBox(height: 18),
          _LoanRow(label: 'Loan amount', value: usd(amount)),
          _LoanRow(label: 'Tenure', value: '$years years'),
          _LoanRow(
              label: 'Interest',
              value: '${bank.annualRate.toStringAsFixed(1)}% p.a.'),
          _LoanRow(label: 'Est. monthly', value: usd(monthly), bold: true),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Submit Application',
            trailingIcon: null,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ),
  );
  if (ok == true && context.mounted) {
    investToast(context,
        'Application sent — ${bank.name} will contact you on Telegram');
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.title, {this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoanRow extends StatelessWidget {
  const _LoanRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: FontWeight.w800,
              color: bold ? AppColors.navy : AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
