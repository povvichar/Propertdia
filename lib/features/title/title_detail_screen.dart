import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/primary_button.dart';
import 'data/title_service.dart';
import 'widgets/title_widgets.dart';

class TitleDetailScreen extends StatefulWidget {
  const TitleDetailScreen({super.key, required this.app});

  final TitleApplication app;

  @override
  State<TitleDetailScreen> createState() => _TitleDetailScreenState();
}

class _TitleDetailScreenState extends State<TitleDetailScreen> {
  bool _notify = true;

  void _toast(String msg) {
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

  @override
  Widget build(BuildContext context) {
    final a = widget.app;
    final verified = a.status == TitleStatus.completed ||
        a.status == TitleStatus.approved;
    final eta = addWorkingDays(a.submittedDate, a.type.workingDays);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Top bar
              Row(
                children: [
                  GlassIconButton(
                    asset: 'assets/icons/base/careleft.svg',
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Application Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  TitleStatusBadge(status: a.status),
                ],
              ),
              const SizedBox(height: 16),

              _SummaryCard(app: a),
              const SizedBox(height: 14),

              if (a.type == TitleServiceType.transfer &&
                  a.propertyValue != null) ...[
                _CostCard(app: a),
                const SizedBox(height: 14),
              ],

              // Status & service timeline
              _Card(
                title: 'Status & timeline',
                trailing: a.status == TitleStatus.completed
                    ? null
                    : _EtaChip(date: eta),
                child: TitleTimeline(
                  status: a.status,
                  submittedDate: a.submittedDate,
                  workingDays: a.type.workingDays,
                ),
              ),
              const SizedBox(height: 14),

              // Documents
              _Card(
                title: 'Submitted documents',
                child: Column(
                  children: [
                    for (final d in a.documents)
                      DocRow(name: d, verified: verified),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Push notifications
              _NotifyCard(
                value: _notify,
                onChanged: (v) {
                  setState(() => _notify = v);
                  _toast(v
                      ? 'Status notifications on'
                      : 'Status notifications off');
                },
              ),
              const SizedBox(height: 14),

              // Customer support
              _SupportCard(onTap: () => _toast('Connecting to support…')),
              const SizedBox(height: 20),

              if (a.status == TitleStatus.completed)
                PrimaryButton(
                  label: 'Download title document',
                  trailingIcon: 'assets/icons/base/downloadsimple.svg',
                  onPressed: () => _toast('Downloading ${a.refNo}.pdf…'),
                ),
              if (a.status == TitleStatus.rejected)
                PrimaryButton(
                  label: 'Re-submit application',
                  onPressed: () =>
                      context.pushReplacement('/title/new', extra: a.type),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.app});

  final TitleApplication app;

  @override
  Widget build(BuildContext context) {
    final a = app;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    a.type.asset,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                        AppColors.navyIcon, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.type.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${a.refNo} · ${a.titleType}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              _Fact(label: 'Address', value: a.address),
              if (a.province.isNotEmpty)
                _Fact(label: 'Province', value: a.province),
              _Fact(
                label: a.transferTo != null ? 'Seller' : 'Applicant',
                value: a.applicantName,
              ),
              if (a.transferTo != null)
                _Fact(label: 'Buyer', value: a.transferTo!),
              _Fact(label: 'Submitted', value: shortDate(a.submittedDate)),
              _Fact(
                label: 'Contact',
                value:
                    '${a.contactWay == ContactWay.telegram ? 'Telegram' : 'Phone'} · ${a.contactInfo}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Transfer cost breakdown: service fee + 4% government transfer tax + total.
class _CostCard extends StatelessWidget {
  const _CostCard({required this.app});

  final TitleApplication app;

  @override
  Widget build(BuildContext context) {
    final fee = app.type.fee;
    final tax = app.transferTax ?? 0;
    return _Card(
      title: 'Cost breakdown',
      child: Column(
        children: [
          _line('Service fee', usd(fee)),
          const SizedBox(height: 10),
          _line('Transfer tax (4%)', usd(tax)),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          _line('Total paid', usd(fee + tax), total: true),
        ],
      ),
    );
  }

  Widget _line(String k, String v, {bool total = false}) {
    return Row(
      children: [
        Text(
          k,
          style: TextStyle(
            fontSize: total ? 14.5 : 13.5,
            fontWeight: total ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          v,
          style: TextStyle(
            fontSize: total ? 18 : 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 32 - 32 - 10) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _EtaChip extends StatelessWidget {
  const _EtaChip({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/base/calendar.svg',
            width: 13,
            height: 13,
            colorFilter:
                const ColorFilter.mode(AppColors.goldDark, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Text(
            'Est. ${shortDate(date)}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.goldDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifyCard extends StatelessWidget {
  const _NotifyCard({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/base/bell.svg',
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Get notified on every status update',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need help?',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Our title specialists are here to assist.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/base/chat.svg',
                    width: 17,
                    height: 17,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
