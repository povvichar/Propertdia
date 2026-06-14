import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/primary_button.dart';
import '../auth/data/account.dart';

// ── Shared scaffold ───────────────────────────────────────────────────────────

class _Screen extends StatelessWidget {
  const _Screen({required this.title, required this.child, this.bottom});

  final String title;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 48,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.navy,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: child,
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: bottom!,
              ),
          ],
        ),
      ),
    );
  }
}

// White rounded card with hairline dividers between rows.
// [dividerInset] shifts the divider left edge to align under row text.
class _Card extends StatelessWidget {
  const _Card({required this.children, this.dividerInset = 16});
  final List<Widget> children;
  final double dividerInset;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Padding(
          padding: EdgeInsets.only(left: dividerInset),
          child: const Divider(height: 1, thickness: 1, color: AppColors.border),
        ));
      }
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: items),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
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

// ── Personal Information ──────────────────────────────────────────────────────

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final account = session.current!;
    return _Screen(
      title: 'Personal Information',
      bottom: PrimaryButton(
        label: 'Edit Profile',
        trailingIcon: null,
        onPressed: () {},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              margin: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppColors.navyDepth,
                shape: BoxShape.circle,
              ),
              child: Text(
                account.initials,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const _SectionLabel('Profile'),
          _Card(children: [
            _LabelValue('Full name', account.name),
            _LabelValue('Email', account.email),
            const _LabelValue('Phone', '+855 12 345 678'),
            _LabelValue('Role', account.role),
            const _LabelValue('Member since', 'Jun 2026'),
          ]),
          const SizedBox(height: 22),
          const _SectionLabel('Account Status'),
          _Card(children: [
            const _LabelValue('KYC', 'Not verified'),
            _LabelValue('Investor', account.investor ? 'Yes' : 'No'),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Identity Verification (KYC) ───────────────────────────────────────────────

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Screen(
      title: 'Identity Verification',
      bottom: PrimaryButton(
        label: 'Start Verification',
        trailingIcon: null,
        onPressed: () {},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Notice banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/base/shield_user.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                      AppColors.goldDark, BlendMode.srcIn),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Verify your identity to unlock deposits, withdrawals and investing.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionLabel('Steps Required'),
          const _Card(children: [
            _KycStep(n: 1, label: 'National ID or passport', done: false),
            _KycStep(n: 2, label: 'Selfie for liveness check', done: false),
            _KycStep(n: 3, label: 'Proof of address', done: false),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _KycStep extends StatelessWidget {
  const _KycStep({required this.n, required this.label, required this.done});
  final int n;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.success : AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: done
                ? SvgPicture.asset(
                    'assets/icons/base/check.svg',
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                        Colors.white, BlendMode.srcIn),
                  )
                : Text(
                    '$n',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Security Settings ─────────────────────────────────────────────────────────

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Screen(
      title: 'Security Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const _SectionLabel('Authentication'),
          const _Card(children: [
            _ToggleRow(label: 'Face ID login', initial: true),
            _ToggleRow(label: 'Two-factor authentication', initial: false),
          ]),
          const SizedBox(height: 22),
          const _SectionLabel('Password'),
          _Card(dividerInset: 50, children: [
            _LinkRow(
              icon: 'assets/icons/base/key.svg',
              label: 'Change Password',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 22),
          const _SectionLabel('Danger Zone'),
          _Card(dividerInset: 50, children: [
            _LinkRow(
              icon: 'assets/icons/base/logout.svg',
              label: 'Sign out all devices',
              danger: true,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Notification Preferences ──────────────────────────────────────────────────

class NotificationPrefsScreen extends StatelessWidget {
  const NotificationPrefsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Screen(
      title: 'Notification Preferences',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          _SectionLabel('Channels'),
          _Card(children: [
            _ToggleRow(label: 'Push notifications', initial: true),
            _ToggleRow(label: 'Email updates', initial: true),
            _ToggleRow(label: 'SMS alerts', initial: false),
          ]),
          SizedBox(height: 22),
          _SectionLabel('Marketing'),
          _Card(children: [
            _ToggleRow(label: 'Promotions & offers', initial: false),
            _ToggleRow(label: 'New property alerts', initial: true),
          ]),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Transaction History ───────────────────────────────────────────────────────

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Screen(
      title: 'Transaction History',
      child: _EmptyState(
        icon: 'assets/icons/base/clock.svg',
        title: 'No transactions yet',
        blurb:
            'Your deposits, withdrawals and investments will appear here.',
      ),
    );
  }
}

// ── Application History ───────────────────────────────────────────────────────

class ApplicationHistoryScreen extends StatelessWidget {
  const ApplicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Screen(
      title: 'Application History',
      child: _EmptyState(
        icon: 'assets/icons/base/document.svg',
        title: 'No applications yet',
        blurb:
            'Title, valuation and loan applications will be listed here.',
      ),
    );
  }
}

// ── Saved Drafts ──────────────────────────────────────────────────────────────

class SavedDraftsScreen extends StatelessWidget {
  const SavedDraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Screen(
      title: 'Saved Drafts',
      child: _EmptyState(
        icon: 'assets/icons/base/save.svg',
        title: 'No saved drafts',
        blurb:
            'Unfinished listings and requests are saved here automatically.',
      ),
    );
  }
}

// ── Telegram Support ──────────────────────────────────────────────────────────

class TelegramSupportScreen extends StatelessWidget {
  const TelegramSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Screen(
      title: 'Telegram Support',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const _SectionLabel('Contact Us'),
          _Card(dividerInset: 50, children: [
            _LinkRow(
              icon: 'assets/icons/base/telegram.svg',
              label: 'Chat on Telegram',
              subtitle: '@propertdia',
              onTap: () {},
            ),
            _LinkRow(
              icon: 'assets/icons/base/phone.svg',
              label: 'Call Support',
              subtitle: '+855 23 999 000',
              onTap: () {},
            ),
            _LinkRow(
              icon: 'assets/icons/base/email.svg',
              label: 'Email Us',
              subtitle: 'support@propertdia.com',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 22),
          const _SectionLabel('Resources'),
          _Card(dividerInset: 50, children: [
            _LinkRow(
              icon: 'assets/icons/base/question.svg',
              label: 'Browse FAQ',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _ToggleRow extends StatefulWidget {
  const _ToggleRow({required this.label, required this.initial});
  final String label;
  final bool initial;

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch.adaptive(
            value: _value,
            activeTrackColor: AppColors.gold,
            onChanged: (v) => setState(() => _value = v),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatefulWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });
  final String icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.danger ? AppColors.danger : AppColors.navyIcon;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? AppColors.surfaceMuted : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(
              widget.icon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: widget.danger
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.blurb,
  });
  final String icon;
  final String title;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    AppColors.textSecondary.withValues(alpha: 0.55),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                blurb,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
