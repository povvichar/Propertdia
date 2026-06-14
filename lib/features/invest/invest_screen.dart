import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'data/invest.dart';
import 'widgets/invest_sheets.dart';
import 'widgets/invest_widgets.dart';

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    InvestTopBar(
                      title: 'Invest & Loan',
                      onBack: () => context.pop(),
                    ),
                    const SizedBox(height: 16),
                    SegmentedTabs(
                      labels: const ['Invest', 'Wallet', 'Loan'],
                      index: _tab,
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: investStore,
                  builder: (context, _) => IndexedStack(
                    index: _tab,
                    children: [
                      _InvestTab(onGoToWallet: () => setState(() => _tab = 1)),
                      _WalletTab(onGoToInvest: () => setState(() => _tab = 0)),
                      const _LoanTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab 1 · Invest ───────────────────────────────────────────────────────────

class _InvestTab extends StatelessWidget {
  const _InvestTab({required this.onGoToWallet});

  final VoidCallback onGoToWallet;

  @override
  Widget build(BuildContext context) {
    final investor = investStore.isInvestor;
    final membership = investStore.membership;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        if (membership == MembershipStatus.none)
          const _MembershipCard()
        else if (membership == MembershipStatus.pending)
          const _PendingReviewCard()
        else
          _InvestorStatusCard(onAddFunds: onGoToWallet),
        const SizedBox(height: 20),
        if (investor) ...[
          _PortfolioCard(onGoToWallet: onGoToWallet),
          const SizedBox(height: 22),
          if (investStore.holdings.isNotEmpty) ...[
            const SectionTitle('My investments'),
            const SizedBox(height: 12),
            for (final h in investStore.holdings) ...[
              _HoldingCard(holding: h),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 10),
          ],
        ],
        const SectionTitle('Open opportunities'),
        const SizedBox(height: 14),
        for (var i = 0; i < mockProjects.length; i++) ...[
          ProjectCard(
            project: mockProjects[i],
            onTap: () => context.push('/invest/detail', extra: mockProjects[i]),
          ),
          if (i != mockProjects.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'INVESTOR CLUB',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Become an Investor',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Request membership to unlock fractional property investing.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          for (final b in investorBenefits) ...[
            _BenefitRow(benefit: b),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 2),
          _GoldButton(
            label: 'Request Membership',
            onTap: () => showMembershipSheet(context),
          ),
        ],
      ),
    );
  }
}

/// Shown while the investor request is awaiting admin approval.
class _PendingReviewCard extends StatelessWidget {
  const _PendingReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/base/clock.svg',
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(AppColors.gold, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Application under review',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Our team is verifying your request. You can invest once approved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
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

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit});

  final InvestorBenefit benefit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: SvgPicture.asset(
              benefit.icon,
              width: 19,
              height: 19,
              colorFilter:
                  const ColorFilter.mode(AppColors.gold, BlendMode.srcIn),
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
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                benefit.blurb,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.68),
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

/// Compact status card shown once the user is an active investor.
class _InvestorStatusCard extends StatelessWidget {
  const _InvestorStatusCard({required this.onAddFunds});

  final VoidCallback onAddFunds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/base/medal.svg',
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(AppColors.gold, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Active Investor',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SvgPicture.asset(
                      'assets/icons/base/check_circle.svg',
                      width: 15,
                      height: 15,
                      colorFilter: const ColorFilter.mode(
                          AppColors.gold, BlendMode.srcIn),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Investor Club member · wallet active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAddFunds,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Add funds',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.onGoToWallet});

  final VoidCallback onGoToWallet;

  @override
  Widget build(BuildContext context) {
    final empty = investStore.holdings.isEmpty;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'My portfolio',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (!empty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${investStore.blendedRoi.toStringAsFixed(1)}% avg ROI',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (empty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No active investments yet. Fund your wallet and back a project to start earning.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onGoToWallet,
                  child: Row(
                    children: [
                      const Text(
                        'Go to wallet',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/icons/base/arrowright.svg',
                        width: 15,
                        height: 15,
                        colorFilter: const ColorFilter.mode(
                            AppColors.navy, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Invested',
                    value: usd(investStore.totalInvested),
                  ),
                ),
                Expanded(
                  child: StatTile(
                    label: 'Projected',
                    value: usd(investStore.projectedValue),
                    valueColor: AppColors.navy,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    label: 'Active deals',
                    value: '${investStore.activeDeals}',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({required this.holding});

  final Holding holding;

  @override
  Widget build(BuildContext context) {
    final h = holding;
    final projected = h.project.projectedReturn(h.amount);
    return GestureDetector(
      onTap: () => context.push('/invest/detail', extra: h.project),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                h.project.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${usd(h.amount)} invested · ${h.project.targetRoi.toStringAsFixed(0)}% ROI',
                    style: const TextStyle(
                      fontSize: 12,
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
                  usd(projected),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const Text(
                  'at maturity',
                  style: TextStyle(
                    fontSize: 10.5,
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

// ── Tab 2 · Wallet ───────────────────────────────────────────────────────────

class _WalletTab extends StatelessWidget {
  const _WalletTab({required this.onGoToInvest});

  final VoidCallback onGoToInvest;

  @override
  Widget build(BuildContext context) {
    if (!investStore.isInvestor) {
      return _WalletLocked(
        pending: investStore.isPendingReview,
        onGoToInvest: onGoToInvest,
      );
    }
    final txns = investStore.transactions;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _BalanceCard(
          balance: investStore.balance,
          onDeposit: () => runDeposit(context),
          onWithdraw: () => runWithdraw(context),
        ),
        const SizedBox(height: 22),
        const SectionTitle('Transaction history'),
        const SizedBox(height: 6),
        if (txns.isEmpty)
          const _WalletEmpty()
        else
          for (final t in txns) _TxnRow(txn: t),
      ],
    );
  }
}

class _WalletLocked extends StatelessWidget {
  const _WalletLocked({required this.pending, required this.onGoToInvest});

  final bool pending;
  final VoidCallback onGoToInvest;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    pending
                        ? 'assets/icons/base/clock.svg'
                        : 'assets/icons/base/locked.svg',
                    width: 30,
                    height: 30,
                    colorFilter: const ColorFilter.mode(
                        AppColors.navyIcon, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                pending ? 'Activation in review' : 'Your wallet is locked',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pending
                    ? 'Your wallet activates as soon as your investor request is approved.'
                    : 'Become an investor to activate your wallet and fund projects.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (pending)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Under admin review',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldDark,
                    ),
                  ),
                )
              else
                _GoldButton(
                  label: 'Become an Investor',
                  onTap: () async {
                    final joined = await showMembershipSheet(context);
                    if (joined == true && context.mounted) onGoToInvest();
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.onDeposit,
    required this.onWithdraw,
  });

  final int balance;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/base/wallet.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.7), BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
              Text(
                'Available balance',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            usd(balance),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'For investing in PROPERTDIA projects',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _WalletAction(
                  icon: 'assets/icons/base/arrowdownleft.svg',
                  label: 'Deposit',
                  filled: true,
                  onTap: onDeposit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletAction(
                  icon: 'assets/icons/base/arrowupright.svg',
                  label: 'Withdraw',
                  filled: false,
                  onTap: onWithdraw,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: filled ? AppColors.gold : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 17,
              height: 17,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletEmpty extends StatelessWidget {
  const _WalletEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 30, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Make your first deposit to get started',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});

  final WalletTxn txn;

  @override
  Widget build(BuildContext context) {
    final credit = txn.kind.isCredit;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                txn.kind.icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  credit ? AppColors.success : AppColors.navyIcon,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${txn.kind.label} · ${txn.date}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (txn.isPending) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${credit ? '+' : '-'}${usd(txn.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: txn.isPending
                  ? AppColors.textSecondary
                  : (credit ? AppColors.success : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 3 · Loan ─────────────────────────────────────────────────────────────

class _LoanTab extends StatefulWidget {
  const _LoanTab();

  @override
  State<_LoanTab> createState() => _LoanTabState();
}

class _LoanTabState extends State<_LoanTab> {
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
        const SectionTitle('Compare local banks'),
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
          label:
              canApply ? 'Apply with ${_bank.name}' : 'Enter ${usd(kLoanMin)}+',
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
                  Expanded(child: _HeroStat(label: 'Term', value: '$years yrs')),
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
