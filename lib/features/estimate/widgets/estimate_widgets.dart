import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/valuation.dart';

/// Small status pill — colored dot + label, tinted background.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.compact = false});

  final ValuationStatus status;
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

/// Vertical progress timeline: Requested → In Review → Approved → Completed.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.status});

  final ValuationStatus status;

  static const _steps = [
    ('Requested', 'Application received'),
    ('In Review', 'Valuer assessing the property'),
    ('Approved', 'Valuation figure confirmed'),
    ('Completed', 'Report ready to download'),
  ];

  @override
  Widget build(BuildContext context) {
    final rejected = status == ValuationStatus.rejected;
    final current = status.step;

    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _TimelineRow(
            title: rejected && i == 2 ? 'Rejected' : _steps[i].$1,
            subtitle: rejected && i == 2
                ? 'Please review and re-submit'
                : _steps[i].$2,
            done: i < current,
            active: i == current,
            rejected: rejected && i == 2,
            isLast: i == _steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.active,
    required this.rejected,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final bool done;
  final bool active;
  final bool rejected;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final reached = done || active;
    final Color color = rejected
        ? AppColors.danger
        : active
            ? AppColors.gold
            : done
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
                child: done
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
                    color: done ? AppColors.success : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: reached
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
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
