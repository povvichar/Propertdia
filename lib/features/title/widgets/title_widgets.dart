import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/list_filter.dart';
import '../data/title_service.dart';

/// Opens a scrollable detail sheet explaining a title service — what it does,
/// the cost & timeline, how it works, and the documents required.
Future<void> showTitleServiceInfo(BuildContext context, TitleServiceType type) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ServiceInfoSheet(type: type),
  );
}

class _ServiceInfoSheet extends StatelessWidget {
  const _ServiceInfoSheet({required this.type});

  final TitleServiceType type;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              type.asset,
                              width: 26,
                              height: 26,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.navyIcon, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.label,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                type.blurb,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _FactTile(
                            icon: 'assets/icons/base/wallet.svg',
                            label: 'Service fee',
                            value: 'From ${usd(type.fee)}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FactTile(
                            icon: 'assets/icons/base/clock.svg',
                            label: 'Processing',
                            value: '~${type.workingDays} working days',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _SheetLabel('About this service'),
                    const SizedBox(height: 8),
                    Text(
                      type.detail,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                        height: 1.55,
                      ),
                    ),
                    if (type == TitleServiceType.transfer) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_rounded,
                                size: 16, color: AppColors.goldDark),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The 4% transfer tax is calculated on the '
                                'declared property value and is separate from '
                                'the service fee above.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    const _SheetLabel('How it works'),
                    const SizedBox(height: 12),
                    for (var i = 0; i < type.steps.length; i++)
                      _StepRow(
                        index: i + 1,
                        text: type.steps[i],
                        isLast: i == type.steps.length - 1,
                      ),
                    const SizedBox(height: 16),
                    const _SheetLabel('Documents you’ll need'),
                    const SizedBox(height: 10),
                    for (final d in type.requiredDocs) _DocLine(text: d),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile(
      {required this.icon, required this.label, required this.value});

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 18,
            height: 18,
            colorFilter:
                const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow(
      {required this.index, required this.text, required this.isLast});

  final int index;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 2),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocLine extends StatelessWidget {
  const _DocLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_rounded,
                size: 16, color: AppColors.success),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small status pill — colored dot + label, tinted background.
class TitleStatusBadge extends StatelessWidget {
  const TitleStatusBadge({super.key, required this.status, this.compact = false});

  final TitleStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical progress + service timeline with milestone dates.
class TitleTimeline extends StatelessWidget {
  const TitleTimeline({
    super.key,
    required this.status,
    required this.submittedDate,
    required this.workingDays,
  });

  final TitleStatus status;
  final DateTime submittedDate;
  final int workingDays;

  @override
  Widget build(BuildContext context) {
    final rejected = status == TitleStatus.rejected;
    final current = status.step;

    final dates = [
      submittedDate,
      addWorkingDays(submittedDate, 2),
      addWorkingDays(submittedDate, (workingDays * 0.7).round()),
      addWorkingDays(submittedDate, workingDays),
    ];

    const steps = [
      ('Requested', 'Application & documents received'),
      ('In Review', 'Document check & cadastral verification'),
      ('Approved', 'Tax assessed · decision confirmed'),
      ('Completed', 'Registered · new title issued'),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _Row(
            title: rejected && i == 2 ? 'Rejected' : steps[i].$1,
            subtitle: rejected && i == 2
                ? 'Please review and re-submit'
                : steps[i].$2,
            date: dates[i],
            reachedDone: i < current,
            active: i == current,
            rejected: rejected && i == 2,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.reachedDone,
    required this.active,
    required this.rejected,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final DateTime date;
  final bool reachedDone;
  final bool active;
  final bool rejected;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final reached = reachedDone || active;
    final Color color = rejected
        ? AppColors.danger
        : active
            ? AppColors.gold
            : reachedDone
                ? AppColors.success
                : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: reached ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: reached ? color : AppColors.border,
                    width: 2,
                  ),
                ),
                child: reachedDone
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : rejected
                        ? const Icon(Icons.close_rounded,
                            size: 14, color: Colors.white)
                        : active
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color:
                        reachedDone ? AppColors.success : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: reached
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '${reached && !active ? '' : 'Est. '}${shortDate(date)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: reached
                              ? AppColors.textSecondary
                              : AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
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

/// Tappable document upload row used in the wizard.
class DocUploadTile extends StatelessWidget {
  const DocUploadTile({
    super.key,
    required this.name,
    required this.uploaded,
    required this.onTap,
  });

  final String name;
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: uploaded
              ? AppColors.success.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: uploaded ? AppColors.success : AppColors.border,
            width: uploaded ? 1.4 : 1,
          ),
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
                  'assets/icons/base/file_text.svg',
                  width: 20,
                  height: 20,
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
                    name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    uploaded ? 'Uploaded · scan.pdf' : 'Tap to upload · PDF/JPG',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: uploaded
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: uploaded ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            uploaded
                ? const Icon(Icons.check_circle_rounded,
                    size: 24, color: AppColors.success)
                : SvgPicture.asset(
                    'assets/icons/base/folder_upload.svg',
                    width: 22,
                    height: 22,
                    colorFilter:
                        const ColorFilter.mode(AppColors.navy, BlendMode.srcIn),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Read-only submitted-document row used in the detail screen.
class DocRow extends StatelessWidget {
  const DocRow({super.key, required this.name, required this.verified});

  final String name;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/base/file_text.svg',
            width: 18,
            height: 18,
            colorFilter:
                const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: (verified ? AppColors.success : AppColors.gold)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              verified ? 'Verified' : 'Submitted',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: verified ? AppColors.success : AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Application list pieces (shared by the hub preview & the history screen) ──

/// One application row: service icon, address, ref/title type, status badge.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.app});

  final TitleApplication app;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/title/detail', extra: app),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  app.type.asset,
                  width: 22,
                  height: 22,
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
                    app.type.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${app.refNo} · ${app.titleType}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TitleStatusBadge(status: app.status, compact: true),
          ],
        ),
      ),
    );
  }
}

/// Opens the shared status-filter sheet for title applications.
Future<void> showTitleStatusFilter(
  BuildContext context, {
  required TitleStatus? selected,
  required List<TitleApplication> apps,
  required ValueChanged<TitleStatus?> onSelect,
}) {
  final options = [
    StatusFilterOption(
      label: 'All',
      color: AppColors.navy,
      count: apps.length,
      selected: selected == null,
    ),
    for (final s in TitleStatus.values)
      StatusFilterOption(
        label: s.label,
        color: s.color,
        count: apps.where((a) => a.status == s).length,
        selected: selected == s,
      ),
  ];
  return showStatusFilterSheet(
    context,
    options: options,
    onSelect: (i) => onSelect(i == 0 ? null : TitleStatus.values[i - 1]),
  );
}
