import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/utils/l10n_ext.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/tier_badge.dart';
import '../auth/data/account.dart';
import '../invest/data/invest.dart';
import 'widgets/profile_sheets.dart' show showLanguage;

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
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
      padding: EdgeInsets.zero,
      children: [
        _ProfileHero(
          avatar: SvgPicture.asset(
            'assets/icons/base/profile.svg',
            width: 44,
            height: 44,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          avatarColor: AppColors.navy,
          name: context.l10n.profileGuestTitle,
          subtitle: context.l10n.profileGuestSubtitle,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
          child: Column(
            children: [
              PrimaryButton(
                label: context.l10n.actionLogIn,
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
                  child: Text(
                    context.l10n.profileCreateAccount,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
            ],
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
      padding: EdgeInsets.zero,
      children: [
        _ProfileHero(
          avatar: Text(
            account.initials,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          avatarColor: AppColors.gold,
          name: account.name,
          role: account.role,
          subtitle: account.email,
          badge: account.investor
              ? TierBadge(investStore.tier, compact: true)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GroupLabel(context.l10n.profileGroupAccount),
        _Group([
          _Row(
            icon: 'assets/icons/base/profile.svg',
            label: context.l10n.profilePersonalInfo,
            onTap: () => context.push('/profile/personal'),
          ),
          _Row(
            icon: 'assets/icons/base/shield_user.svg',
            label: context.l10n.profileIdentityVerification,
            trailing:
                _StatusChip(context.l10n.profileNotVerified, AppColors.gold),
            onTap: () => context.push('/profile/kyc'),
          ),
          _Row(
            icon: 'assets/icons/base/locked.svg',
            label: context.l10n.profileSecurity,
            onTap: () => context.push('/profile/security'),
          ),
        ]),
        const SizedBox(height: 22),

        _GroupLabel(context.l10n.profileGroupActivity),
        _Group([
          _Row(
            icon: 'assets/icons/base/clock.svg',
            label: context.l10n.profileTransactionHistory,
            onTap: () => context.push('/profile/transactions'),
          ),
          _Row(
            icon: 'assets/icons/base/document.svg',
            label: context.l10n.profileApplicationHistory,
            onTap: () => context.push('/profile/applications'),
          ),
          _Row(
            icon: 'assets/icons/base/save.svg',
            label: context.l10n.profileSavedDrafts,
            onTap: () => context.push('/profile/drafts'),
          ),
        ]),
        const SizedBox(height: 22),

        _GroupLabel(context.l10n.profileGroupPreferences),
        _Group([
          _Row(
            icon: 'assets/icons/base/bell.svg',
            label: context.l10n.profileNotificationPrefs,
            onTap: () => context.push('/profile/notifications'),
          ),
          _Row(
            icon: 'assets/icons/base/world.svg',
            label: context.l10n.profileLanguage,
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

        _GroupLabel(context.l10n.profileGroupSupport),
        _Group([
          _Row(
            icon: 'assets/icons/base/chat.svg',
            label: context.l10n.profileHelpSupport,
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
                Text(
                  context.l10n.profileSignOut,
                  style: const TextStyle(
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
          ),
        ),
      ],
    );
  }
}

/// Navy header with an overlapping circular avatar — mirrors the team profile
/// screen. [avatar] is the circle's content (initials or an icon).
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.avatar,
    required this.avatarColor,
    required this.name,
    this.role,
    this.subtitle,
    this.badge,
  });

  final Widget avatar;
  final Color avatarColor;
  final String name;
  final String? role;
  final String? subtitle;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        SizedBox(
          height: 196 + topInset,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150 + topInset,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroHeader,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: avatarColor,
                      child: avatar,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (role != null) ...[
          const SizedBox(height: 4),
          Text(
            role!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        if (badge != null) ...[
          const SizedBox(height: 12),
          badge!,
        ],
      ],
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
