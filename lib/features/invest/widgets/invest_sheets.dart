import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tier_badge.dart';
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  Expanded(
                      child: _MethodChip(
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
Future<void> runDeposit(BuildContext context) =>
    context.push('/invest/deposit');

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
  // Membership gate first — application needs admin approval before investing.
  if (!investStore.isInvestor) {
    if (investStore.isPendingReview) {
      investToast(context, 'Your investor application is under review');
      return;
    }
    context.push('/invest/apply');
    return;
  }

  // Tier gate — early / priority access deals require a higher rank.
  if (!investStore.canInvestIn(project)) {
    investToast(
        context, 'Early access — available to ${project.minTier.label}+ members');
    return;
  }

  // Needs funds.
  if (investStore.balance < project.minInvest) {
    final topUp = await _showInsufficientSheet(context, project);
    if (topUp != true || !context.mounted) return;
    await runDeposit(context);
    if (!context.mounted || investStore.balance < project.minInvest) return;
  }

  // Per-deal cap is the lower of wallet balance and the tier's investment limit.
  final tierCap = investStore.tierMaxInvest;
  final cap = investStore.balance < tierCap ? investStore.balance : tierCap;
  final overMax = investStore.balance > tierCap
      ? 'Above your ${investStore.tier.label} limit (${investStore.tier.maxInvestLabel})'
      : 'More than your wallet balance';
  final r = await showAmountSheet(
    context,
    title: 'Invest in ${project.name}',
    subtitle:
        'Min ${usd(project.minInvest)} · wallet ${usd(investStore.balance)}',
    cta: 'Confirm Investment',
    min: project.minInvest,
    max: cap,
    quick: [
      project.minInvest,
      project.minInvest * 2,
      if (cap >= project.minInvest) cap,
    ],
    overMaxLabel: overMax,
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

// ── Tier info ────────────────────────────────────────────────────────────────

/// Read-only sheet explaining the three investor ranks: how each is reached and
/// what it unlocks. Opened from the ⓘ on the wallet card / tier card.
Future<void> showTierInfoSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetTitle(
            'Investor tiers',
            subtitle:
                'Your rank starts from your application and climbs as you '
                'invest. Higher tiers unlock more.',
          ),
          const SizedBox(height: 18),
          for (final t in InvestorTier.values) ...[
            _TierInfoRow(tier: t),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
  );
}

class _TierInfoRow extends StatelessWidget {
  const _TierInfoRow({required this.tier});

  final InvestorTier tier;

  @override
  Widget build(BuildContext context) {
    final reach = switch (tier) {
      InvestorTier.silver =>
        'Entry rank · invest up to ${tier.maxInvestLabel} per deal.',
      InvestorTier.gold =>
        '${usd(kGoldThreshold)}+ in assets or invested · up to '
            '${tier.maxInvestLabel} per deal · early deal access.',
      InvestorTier.platinum =>
        '${usd(kPlatinumThreshold)}+ in assets or invested · '
            'unlimited per deal · priority access to every deal.',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tier.colorSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TierBadge(tier),
          const SizedBox(height: 8),
          Text(
            reach,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legal & protections ──────────────────────────────────────────────────────

/// Read-only sheet detailing how the investment is safeguarded, opened from the
/// "Protected investment" banner on the project detail.
Future<void> showProtectionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetTitle(
            'Legal & protections',
            subtitle: 'How PROPERTDIA safeguards your investment.',
          ),
          const SizedBox(height: 18),
          for (final pr in kProjectProtections) _ProtectionSheetRow(protection: pr),
        ],
      ),
    ),
  );
}

class _ProtectionSheetRow extends StatelessWidget {
  const _ProtectionSheetRow({required this.protection});

  final ProjectProtection protection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                protection.icon,
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(AppColors.success, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  protection.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  protection.blurb,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
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

// ── Document preview ───────────────────────────────────────────────────────

/// Lightweight document viewer sheet (demo): shows the file, then "downloads".
Future<void> showDocSheet(BuildContext context, ProjectDoc doc) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/base/file_text.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                        AppColors.danger, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PDF · ${doc.size}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'This document is verified by PROPERTDIA. Preview opens in your '
            'reader once downloaded.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.95),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Download PDF',
            trailingIcon: 'assets/icons/base/downloadsimple.svg',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              investToast(context, 'Downloaded ${doc.name}');
            },
          ),
        ],
      ),
    ),
  );
}

/// Read-only sheet listing the Investor Club benefits, opened from the
/// info (ⓘ) button on the membership card.
Future<void> showInvestorBenefitsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetTitle(
            'Investor benefits',
            subtitle: 'What you unlock as an Investor Club member.',
          ),
          const SizedBox(height: 18),
          for (final b in investorBenefits) ...[
            _BenefitSheetRow(benefit: b),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 2),
        ],
      ),
    ),
  );
}

/// One investor benefit, styled for a light bottom sheet.
class _BenefitSheetRow extends StatelessWidget {
  const _BenefitSheetRow({required this.benefit});

  final InvestorBenefit benefit;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              benefit.icon,
              width: 18,
              height: 18,
              colorFilter:
                  const ColorFilter.mode(AppColors.goldDark, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                benefit.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                benefit.blurb,
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
    );
  }
}
