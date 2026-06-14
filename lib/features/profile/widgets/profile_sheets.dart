import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/data/account.dart';

void _toast(BuildContext context, String msg) {
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

Future<T?> _show<T>(BuildContext context, String title, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _Shell(title: title, child: child),
  );
}

class _Shell extends StatelessWidget {
  const _Shell({required this.title, required this.child});

  final String title;
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Personal Information ─────────────────────────────────────────────────────

void showPersonalInfo(BuildContext context, Account a) {
  _show(
    context,
    'Personal Information',
    Column(
      children: [
        _InfoRow('Full name', a.name),
        _InfoRow('Email', a.email),
        const _InfoRow('Phone', '+855 12 345 678'),
        _InfoRow('Role', a.role),
        const _InfoRow('Member since', 'Jun 2026'),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Edit profile',
          trailingIcon: null,
          onPressed: () {
            Navigator.of(context).pop();
            _toast(context, 'Profile editing coming soon');
          },
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Identity Verification (KYC) ──────────────────────────────────────────────

void showKyc(BuildContext context) {
  _show(
    context,
    'Identity Verification',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.goldSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/base/shield_user.svg',
                width: 22,
                height: 22,
                colorFilter:
                    const ColorFilter.mode(AppColors.goldDark, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Verify your identity to unlock deposits, withdrawals and investing.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _Step(n: 1, label: 'National ID or passport'),
        const _Step(n: 2, label: 'Selfie for liveness check'),
        const _Step(n: 3, label: 'Proof of address'),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Start verification',
          trailingIcon: null,
          onPressed: () {
            Navigator.of(context).pop();
            _toast(context, 'KYC flow coming soon');
          },
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.label});

  final int n;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$n',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle sheets (Notifications / Security) ─────────────────────────────────

void showNotifications(BuildContext context) {
  _show(
    context,
    'Notification Preferences',
    const _Toggles(items: [
      ('Push notifications', true),
      ('Email updates', true),
      ('SMS alerts', false),
      ('Promotions & offers', false),
    ]),
  );
}

void showSecurity(BuildContext context) {
  _show(
    context,
    'Security Settings',
    Column(
      children: [
        const _Toggles(items: [
          ('Face ID login', true),
          ('Two-factor authentication', false),
        ]),
        const SizedBox(height: 8),
        _LinkRow(
          icon: 'assets/icons/base/key.svg',
          label: 'Change password',
          onTap: () {
            Navigator.of(context).pop();
            _toast(context, 'Password change coming soon');
          },
        ),
      ],
    ),
  );
}

class _Toggles extends StatefulWidget {
  const _Toggles({required this.items});

  final List<(String, bool)> items;

  @override
  State<_Toggles> createState() => _TogglesState();
}

class _TogglesState extends State<_Toggles> {
  late final List<bool> _values =
      widget.items.map((e) => e.$2).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.items[i].$1,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: _values[i],
                  activeTrackColor: AppColors.gold,
                  onChanged: (v) => setState(() => _values[i] = v),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter:
                  const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/icons/base/careright.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language ─────────────────────────────────────────────────────────────────

void showLanguage(BuildContext context) {
  _show(
    context,
    'Language',
    Consumer(
      builder: (context, ref, _) {
        final current = ref.watch(languageProvider);
        Widget option(AppLanguage lang, String label, String flag) {
          final sel = current == lang;
          return GestureDetector(
            onTap: () => ref.read(languageProvider.notifier).state = lang,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sel ? AppColors.goldSoft : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.gold : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(flag, width: 24, height: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (sel)
                    SvgPicture.asset(
                      'assets/icons/base/check_circle.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                          AppColors.goldDark, BlendMode.srcIn),
                    ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            option(AppLanguage.english, 'English',
                'assets/icons/base/english.svg'),
            option(AppLanguage.khmer, 'ភាសាខ្មែរ',
                'assets/icons/base/khmer.svg'),
          ],
        );
      },
    ),
  );
}

// ── Empty-state sheets ───────────────────────────────────────────────────────

void showTransactions(BuildContext context) => _show(
      context,
      'Transaction History',
      const _EmptyState(
        icon: 'assets/icons/base/history.svg',
        title: 'No transactions yet',
        blurb: 'Your deposits, withdrawals and investments will appear here.',
      ),
    );

void showApplications(BuildContext context) => _show(
      context,
      'Application History',
      const _EmptyState(
        icon: 'assets/icons/base/file_text.svg',
        title: 'No applications yet',
        blurb: 'Title, valuation and loan applications will be listed here.',
      ),
    );

void showDrafts(BuildContext context) => _show(
      context,
      'Saved Drafts',
      const _EmptyState(
        icon: 'assets/icons/base/edit.svg',
        title: 'No saved drafts',
        blurb: 'Unfinished listings and requests are saved here automatically.',
      ),
    );

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
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
                icon,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                    AppColors.textSecondary.withValues(alpha: 0.6),
                    BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            blurb,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Support Center ───────────────────────────────────────────────────────────

void showSupport(BuildContext context) {
  _show(
    context,
    'Support Center',
    Column(
      children: [
        _LinkRow(
          icon: 'assets/icons/base/telegram.svg',
          label: 'Chat on Telegram',
          onTap: () {
            Navigator.of(context).pop();
            _toast(context, 'Opening Telegram @propertdia');
          },
        ),
        _LinkRow(
          icon: 'assets/icons/base/phone.svg',
          label: 'Call +855 23 999 000',
          onTap: () {
            Navigator.of(context).pop();
            _toast(context, 'Calling support…');
          },
        ),
        _LinkRow(
          icon: 'assets/icons/base/email.svg',
          label: 'Email support@propertdia.com',
          onTap: () {
            Navigator.of(context).pop();
            _toast(context, 'Opening email…');
          },
        ),
        _LinkRow(
          icon: 'assets/icons/base/question.svg',
          label: 'Browse FAQ',
          onTap: () {
            Navigator.of(context).pop();
            _toast(context, 'FAQ coming soon');
          },
        ),
      ],
    ),
  );
}
