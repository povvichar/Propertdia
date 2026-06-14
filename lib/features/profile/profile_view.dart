import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/primary_button.dart';
import '../auth/data/account.dart';
import '../invest/data/invest.dart';
import 'widgets/profile_sheets.dart' show showLanguage;

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) => session.isGuest
            ? const _GuestView()
            : _SignedInView(account: session.current!, lang: ref.watch(languageProvider)),
      ),
    );
  }
}

// ── Guest ────────────────────────────────────────────────────────────────────

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              gradient: AppColors.navyDepth,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/base/profile.svg',
                width: 40,
                height: 40,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            "You're browsing as a guest",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Log in to save favorites, invest in projects\nand manage your wallet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary.withValues(alpha: 0.95),
            ),
          ),
        ),
        const SizedBox(height: 26),
        PrimaryButton(
          label: 'Log in',
          trailingIcon: null,
          onPressed: () => context.push('/login'),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Create account',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Signed in ────────────────────────────────────────────────────────────────

class _SignedInView extends StatelessWidget {
  const _SignedInView({required this.account, required this.lang});

  final Account account;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        _Header(account: account),
        const SizedBox(height: 20),

        const _GroupLabel('Account'),
        _Group([
          _Row(
            icon: 'assets/icons/base/profile.svg',
            label: 'Personal Information',
            onTap: () => context.push('/profile/personal'),
          ),
          _Row(
            icon: 'assets/icons/base/shield_user.svg',
            label: 'Identity Verification',
            trailing: const _StatusChip('Not verified', AppColors.gold),
            onTap: () => context.push('/profile/kyc'),
          ),
          _Row(
            icon: 'assets/icons/base/locked.svg',
            label: 'Security Settings',
            onTap: () => context.push('/profile/security'),
          ),
        ]),
        const SizedBox(height: 22),

        const _GroupLabel('Activity'),
        _Group([
          _Row(
            icon: 'assets/icons/base/clock.svg',
            label: 'Transaction History',
            onTap: () => context.push('/profile/transactions'),
          ),
          _Row(
            icon: 'assets/icons/base/document.svg',
            label: 'Application History',
            onTap: () => context.push('/profile/applications'),
          ),
          _Row(
            icon: 'assets/icons/base/save.svg',
            label: 'Saved Drafts',
            onTap: () => context.push('/profile/drafts'),
          ),
        ]),
        const SizedBox(height: 22),

        const _GroupLabel('Preferences'),
        _Group([
          _Row(
            icon: 'assets/icons/base/bell.svg',
            label: 'Notification Preferences',
            onTap: () => context.push('/profile/notifications'),
          ),
          _Row(
            icon: 'assets/icons/base/world.svg',
            label: 'Language',
            trailing: Text(
              lang == AppLanguage.khmer ? 'ភាសាខ្មែរ' : 'English',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () => showLanguage(context),
          ),
        ]),
        const SizedBox(height: 22),

        const _GroupLabel('Support'),
        _Group([
          _Row(
            icon: 'assets/icons/base/telegram.svg',
            label: 'Telegram Support',
            onTap: () => context.push('/profile/support'),
          ),
        ]),
        const SizedBox(height: 20),

        GestureDetector(
          onTap: () {
            session.signOut();
            investStore.signInNormal();
          },
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/base/logout.svg',
                  width: 18,
                  height: 18,
                  colorFilter:
                      const ColorFilter.mode(AppColors.danger, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sign out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.account});

  final Account account;

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
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              account.initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
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
                    Flexible(
                      child: Text(
                        account.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (account.investor)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Investor',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  account.email,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.7),
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

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary.withValues(alpha: 0.8),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// An iOS-style inset-grouped card: rows share one rounded white container
/// with hairline dividers between them.
class _Group extends StatelessWidget {
  const _Group(this.rows);

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(
          const Padding(
            padding: EdgeInsets.only(left: 52),
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
        );
      }
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? AppColors.surfaceMuted : Colors.white,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Center(
                child: SvgPicture.asset(
                  widget.icon,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                      AppColors.navyIcon, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (widget.trailing != null) ...[
              widget.trailing!,
              const SizedBox(width: 8),
            ],
            SvgPicture.asset(
              'assets/icons/base/careright.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color == AppColors.gold ? AppColors.goldDark : color,
        ),
      ),
    );
  }
}
