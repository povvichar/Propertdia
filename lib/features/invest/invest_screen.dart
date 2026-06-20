import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/tier_badge.dart';
import 'data/invest.dart';
import 'widgets/invest_sheets.dart';
import 'widgets/invest_widgets.dart';

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: investStore,
            builder: (context, _) {
              // Single-purpose Invest hub. The wallet lives inside the Invest
              // tab, and an investor's portfolio sits on its own screen behind
              // the briefcase action in the top bar. (Loan is now its own
              // top-level feature — see lib/features/loan.)
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: InvestTopBar(
                      title: 'Invest',
                      onBack: () => context.pop(),
                      trailing: investStore.isInvestor
                          ? GlassIconButton(
                              asset: 'assets/icons/base/suitcase.svg',
                              onTap: () => context.push('/invest/portfolio'),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Expanded(child: _InvestTab()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── My Portfolio (own screen, reached from the briefcase action) ─────────────

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: investStore,
            builder: (context, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: InvestTopBar(
                      title: 'My Portfolio',
                      onBack: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: [
                        const _TierCard(),
                        const SizedBox(height: 16),
                        const _PortfolioCard(),
                        if (investStore.holdings.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const SectionTitle('My investments'),
                          const SizedBox(height: 12),
                          for (final h in investStore.holdings) ...[
                            _HoldingCard(holding: h),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Transaction history (own screen, reached from the wallet card) ───────────

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: investStore,
            builder: (context, _) {
              final txns = investStore.transactions;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: InvestTopBar(
                      title: 'Transaction history',
                      onBack: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: [
                        if (txns.isEmpty)
                          const _WalletEmpty()
                        else
                          for (final t in txns) _TxnRow(txn: t),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Membership-tier hub shown atop the portfolio: current rank, its perks and
/// progress toward the next rank.
class _TierCard extends StatelessWidget {
  const _TierCard();

  @override
  Widget build(BuildContext context) {
    final tier = investStore.tier;
    final access = switch (tier) {
      InvestorTier.silver => 'Standard',
      InvestorTier.gold => 'Early access',
      InvestorTier.platinum => 'Priority access',
    };
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
              TierBadge(tier),
              const Spacer(),
              GestureDetector(
                onTap: () => showTierInfoSheet(context),
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PerkRow(
            icon: 'assets/icons/base/dollar_square.svg',
            label: 'Per-deal limit',
            value: tier.maxInvestLabel,
          ),
          const SizedBox(height: 12),
          _PerkRow(
            icon: 'assets/icons/base/clock.svg',
            label: 'Deal access',
            value: access,
          ),
          if (investStore.nextTier != null) ...[
            const SizedBox(height: 16),
            Text(
              'Invest ${usd(investStore.nextTierRemaining)} more to reach ${investStore.nextTier!.label}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: investStore.tierProgress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation(investStore.nextTier!.color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  const _PerkRow({required this.icon, required this.label, required this.value});

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              width: 17,
              height: 17,
              colorFilter:
                  const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── All opportunities (own screen, reached from "See all") ───────────────────

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: investStore,
            builder: (context, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: InvestTopBar(
                      title: 'Opportunities',
                      onBack: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: mockProjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => ProjectListItem(
                        project: mockProjects[i],
                        onTap: () => context.push('/invest/detail',
                            extra: mockProjects[i]),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'See all',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 3),
          SvgPicture.asset(
            'assets/icons/base/arrowright.svg',
            width: 14,
            height: 14,
            colorFilter:
                const ColorFilter.mode(AppColors.navy, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

// ── Tab 1 · Invest ───────────────────────────────────────────────────────────

class _InvestTab extends StatelessWidget {
  const _InvestTab();

  @override
  Widget build(BuildContext context) {
    final investor = investStore.isInvestor;
    final membership = investStore.membership;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        // Active investors see a single wallet card (which carries the
        // Investor Club badge); non-members see the join card; pending
        // members see the review card.
        if (investor) ...[
          _BalanceCard(
            balance: investStore.balance,
            onDeposit: () => runDeposit(context),
            onWithdraw: () => runWithdraw(context),
          ),
          const SizedBox(height: 22),
        ] else if (membership == MembershipStatus.pending) ...[
          const _PendingReviewCard(),
          const SizedBox(height: 20),
        ] else ...[
          const _MembershipCard(),
          const SizedBox(height: 20),
        ],
        SectionTitle(
          'Open opportunities',
          trailing: _SeeAllButton(
            onTap: () => context.push('/invest/opportunities'),
          ),
        ),
        const SizedBox(height: 14),
        // Preview the first few; the full catalogue lives behind "See all".
        for (var i = 0; i < _previewCount; i++) ...[
          ProjectCard(
            project: mockProjects[i],
            onTap: () => context.push('/invest/detail', extra: mockProjects[i]),
          ),
          if (i != _previewCount - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  int get _previewCount =>
      mockProjects.length < 3 ? mockProjects.length : 3;
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroHeader,
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              const Spacer(),
              // Member benefits now live behind this info button.
              GestureDetector(
                onTap: () => showInvestorBenefitsSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
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
          const SizedBox(height: 20),
          _GoldButton(
            label: 'Apply for Membership',
            onTap: () => context.push('/invest/apply'),
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
    return GestureDetector(
      // Demo control: long-press simulates an admin approving the request.
      // (Membership otherwise stays pending — there is no auto-approval.)
      onLongPress: () {
        investStore.approveMembership();
        investToast(context, 'Membership approved — welcome to the club');
      },
      child: Container(
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
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Application under review',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PENDING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
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
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard();

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
                  onTap: () => runDeposit(context),
                  child: Row(
                    children: [
                      const Text(
                        'Deposit funds',
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

// ── Wallet balance + transactions (reused on Invest tab & Portfolio) ─────────

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
              TierBadge(investStore.tier, onDark: true),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/invest/transactions'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/base/history.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                          Colors.white.withValues(alpha: 0.85), BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => showTierInfoSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          if (investStore.nextTier != null) ...[
            const SizedBox(height: 14),
            Text(
              'Invest ${usd(investStore.nextTierRemaining)} more to reach ${investStore.nextTier!.label}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: investStore.tierProgress,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                valueColor: AlwaysStoppedAnimation(investStore.nextTier!.color),
              ),
            ),
          ],
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
