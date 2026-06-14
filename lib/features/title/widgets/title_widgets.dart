import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../data/title_service.dart';

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
      ('Requested', 'Application received'),
      ('In Review', 'Cadastral office assessing'),
      ('Approved', 'Decision confirmed'),
      ('Completed', 'Documents ready'),
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
