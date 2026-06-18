import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/list_filter.dart';
import '../data/valuation.dart';

/// Dark navy value card showing an estimated figure + confidence range.
///
/// Two modes: an [certified] figure (approved by a valuer) or an *indicative*
/// auto-computed estimate, which carries a small badge + disclaimer so it's
/// never mistaken for a certified valuation.
class EstimateRangeCard extends StatelessWidget {
  const EstimateRangeCard({
    super.key,
    required this.value,
    required this.comparables,
    this.low,
    this.high,
    this.certified = false,
    this.basis,
    this.showDisclaimer = true,
  });

  final int value;
  final int comparables;
  final int? low;
  final int? high;
  final bool certified;
  final String? basis;
  final bool showDisclaimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.navyDepth,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                certified ? 'Certified market value' : 'Indicative estimate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 8),
              if (!certified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Estimate',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              const Spacer(),
              SvgPicture.asset(
                'assets/icons/base/scale.svg',
                width: 18,
                height: 18,
                colorFilter:
                    const ColorFilter.mode(AppColors.gold, BlendMode.srcIn),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            usd(value),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          if (low != null && high != null)
            Text(
              'Range ${usd(low!)} – ${usd(high!)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gold.withValues(alpha: 0.95),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            basis ?? 'Based on $comparables comparable properties',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          if (!certified && showDisclaimer) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: Colors.white.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto-generated guide price — not a certified valuation.',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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

// ── Valuation list pieces (shared by the hub preview & the history screen) ───

/// One valuation row: type icon, address, ref/date, status badge, and (when an
/// estimate is attached) the indicative/certified figure.
class ValuationCard extends StatelessWidget {
  const ValuationCard({super.key, required this.valuation});

  final Valuation valuation;

  @override
  Widget build(BuildContext context) {
    final v = valuation;
    return GestureDetector(
      onTap: () => context.push('/estimate/detail', extra: v),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Row(
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
                      v.type.asset,
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
                        v.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${v.refNo} · ${shortDate(v.submittedDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: v.status, compact: true),
              ],
            ),
            if (v.hasEstimate) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    v.isIndicative ? 'Indicative value' : 'Certified value',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.95),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    usd(v.estimatedValue!),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Opens the shared status-filter sheet for valuations.
Future<void> showValuationStatusFilter(
  BuildContext context, {
  required ValuationStatus? selected,
  required List<Valuation> items,
  required ValueChanged<ValuationStatus?> onSelect,
}) {
  final options = [
    StatusFilterOption(
      label: 'All',
      color: AppColors.navy,
      count: items.length,
      selected: selected == null,
    ),
    for (final s in ValuationStatus.values)
      StatusFilterOption(
        label: s.label,
        color: s.color,
        count: items.where((v) => v.status == s).length,
        selected: selected == s,
      ),
  ];
  return showStatusFilterSheet(
    context,
    options: options,
    onSelect: (i) => onSelect(i == 0 ? null : ValuationStatus.values[i - 1]),
  );
}
