import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/invest.dart';

void investToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        content: Text(msg),
      ),
    );
}

// ── Sheet chrome ─────────────────────────────────────────────────────────────

class SheetShell extends StatelessWidget {
  const SheetShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
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

// ── Amount entry sheet (deposit / withdraw / invest) ─────────────────────────

class AmountResult {
  const AmountResult(this.amount, this.method);
  final int amount;
  final String method;
}

Future<AmountResult?> showAmountSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String cta,
  int min = 0,
  int? max,
  bool withMethod = false,
  List<int> quick = const [],
  String overMaxLabel = 'Amount exceeds available balance',
}) {
  return showModalBottomSheet<AmountResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AmountSheet(
      title: title,
      subtitle: subtitle,
      cta: cta,
      min: min,
      max: max,
      withMethod: withMethod,
      quick: quick,
      overMaxLabel: overMaxLabel,
    ),
  );
}

class _AmountSheet extends StatefulWidget {
  const _AmountSheet({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.min,
    required this.max,
    required this.withMethod,
    required this.quick,
    required this.overMaxLabel,
  });

  final String title;
  final String? subtitle;
  final String cta;
  final int min;
  final int? max;
  final bool withMethod;
  final List<int> quick;
  final String overMaxLabel;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  final _controller = TextEditingController();
  String _method = payMethods.first.name;

  int get _amount => int.tryParse(_controller.text) ?? 0;

  String? get _error {
    final a = _amount;
    if (a <= 0) return null; // nothing typed yet → no error, just disabled
    if (widget.min > 0 && a < widget.min) {
      return 'Minimum is ${usd(widget.min)}';
    }
    if (widget.max != null && a > widget.max!) return widget.overMaxLabel;
    return null;
  }

  bool get _valid =>
      _amount > 0 &&
      (widget.min == 0 || _amount >= widget.min) &&
      (widget.max == null || _amount <= widget.max!);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetTitle(widget.title, subtitle: widget.subtitle),
          const SizedBox(height: 24),

          // Clean centered amount field with an underline.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.2,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: _error != null ? AppColors.danger : AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Quick amounts
          if (widget.quick.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final q in widget.quick)
                  GestureDetector(
                    onTap: () => setState(() {
                      _controller.text = '$q';
                      _controller.selection = TextSelection.collapsed(
                          offset: _controller.text.length);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: _amount == q
                            ? AppColors.navy
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        usd(q),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _amount == q ? Colors.white : AppColors.navy,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // Method selector
          if (widget.withMethod) ...[
            const SizedBox(height: 20),
            const Text(
              'Via',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final m in payMethods) ...[
                  Expanded(child: _MethodChip(
                    method: m,
                    selected: _method == m.name,
                    onTap: () => setState(() => _method = m.name),
                  )),
                  if (m != payMethods.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ],

          const SizedBox(height: 22),
          PrimaryButton(
            label: widget.cta,
            enabled: _valid,
            trailingIcon: null,
            onPressed: () {
              if (!_valid) return;
              Navigator.of(context).pop(AmountResult(_amount, _method));
            },
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PayMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 22,
              child: SvgPicture.asset(method.logo, fit: BoxFit.contain),
            ),
            const SizedBox(height: 4),
            Text(
              method.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── High-level flows ─────────────────────────────────────────────────────────

/// Deposit runs as a full-screen flow so an in-progress payment can't be
/// dismissed by accident. See `DepositScreen`.
Future<void> runDeposit(BuildContext context) => context.push('/invest/deposit');

Future<void> runWithdraw(BuildContext context) async {
  if (investStore.balance <= 0) {
    investToast(context, 'No funds available to withdraw');
    return;
  }
  final r = await showAmountSheet(
    context,
    title: 'Withdraw',
    subtitle: 'Available ${usd(investStore.balance)} · sent to your bank.',
    cta: 'Withdraw',
    min: 10,
    max: investStore.balance,
    withMethod: true,
  );
  if (r == null || !context.mounted) return;
  if (investStore.withdraw(r.amount, r.method)) {
    investToast(context, '${usd(r.amount)} sent to ${r.method}');
  }
}

/// Invest flow with a built-in "insufficient balance → deposit" path.
Future<void> runInvest(BuildContext context, InvestProject project) async {
  // Membership gate first — request needs admin approval before investing.
  if (!investStore.isInvestor) {
    if (investStore.isPendingReview) {
      investToast(context, 'Your investor application is under review');
      return;
    }
    final requested = await showMembershipSheet(context);
    if (requested == true && context.mounted) {
      investToast(context, 'Request submitted — under admin review');
    }
    return;
  }

  // Needs funds.
  if (investStore.balance < project.minInvest) {
    final topUp = await _showInsufficientSheet(context, project);
    if (topUp != true || !context.mounted) return;
    await runDeposit(context);
    if (!context.mounted || investStore.balance < project.minInvest) return;
  }

  final r = await showAmountSheet(
    context,
    title: 'Invest in ${project.name}',
    subtitle:
        'Min ${usd(project.minInvest)} · wallet ${usd(investStore.balance)}',
    cta: 'Confirm Investment',
    min: project.minInvest,
    max: investStore.balance,
    quick: [
      project.minInvest,
      project.minInvest * 2,
      if (investStore.balance >= project.minInvest) investStore.balance,
    ],
    overMaxLabel: 'More than your wallet balance',
  );
  if (r == null || !context.mounted) return;
  if (investStore.invest(project, r.amount)) {
    investToast(context, '${usd(r.amount)} invested in ${project.name}');
  }
}

Future<bool?> _showInsufficientSheet(
    BuildContext context, InvestProject project) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetTitle(
            'Add funds to invest',
            subtitle:
                'This project needs at least ${usd(project.minInvest)}. Your wallet holds ${usd(investStore.balance)}.',
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Deposit Funds',
            trailingIcon: null,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ),
  );
}

// ── Membership flow ──────────────────────────────────────────────────────────

Future<bool?> showMembershipSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'INVESTOR CLUB',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.goldDark,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _SheetTitle(
            'Become an Investor',
            subtitle:
                'Membership unlocks fractional investing and activates your wallet.',
          ),
          const SizedBox(height: 18),
          for (final b in investorBenefits) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      b.icon,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                          AppColors.goldDark, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        b.blurb,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 4),
          PrimaryButton(
            label: 'Submit Request',
            trailingIcon: null,
            onPressed: () {
              investStore.requestMembership();
              Navigator.of(context).pop(true);
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Reviewed by our team · approved within 24h',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

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
              label: 'Interest', value: '${bank.annualRate.toStringAsFixed(1)}% p.a.'),
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
    investToast(
        context, 'Application sent — ${bank.name} will contact you on Telegram');
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
