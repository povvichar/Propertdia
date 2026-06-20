import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/primary_button.dart';
import 'data/valuation.dart';
import 'widgets/estimate_widgets.dart';

class ValuationDetailScreen extends StatelessWidget {
  const ValuationDetailScreen({super.key, required this.valuation});

  final Valuation valuation;

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

  @override
  Widget build(BuildContext context) {
    final v = valuation;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _TopBar(status: v.status),
              const SizedBox(height: 16),
              _SummaryCard(valuation: v),
              if (v.hasEstimate) ...[
                const SizedBox(height: 14),
                EstimateRangeCard(
                  value: v.estimatedValue!,
                  low: v.valueLow,
                  high: v.valueHigh,
                  comparables: v.comparables,
                  certified: v.hasValue,
                ),
              ],
              const SizedBox(height: 14),
              _Card(
                title: 'Progress',
                child: StatusTimeline(status: v.status),
              ),
              const SizedBox(height: 20),
              if (v.status == ValuationStatus.completed)
                PrimaryButton(
                  label: 'Download PDF Report',
                  trailingIcon: 'assets/icons/base/downloadsimple.svg',
                  onPressed: () =>
                      _toast(context, 'Downloading ${v.refNo}.pdf…'),
                ),
              if (v.status == ValuationStatus.rejected)
                PrimaryButton(
                  label: 'Re-submit request',
                  onPressed: () => context.pushReplacement(
                    '/estimate/new',
                    extra: EstimatePrefill(type: v.type),
                  ),
                ),
              if (v.status == ValuationStatus.completed ||
                  v.status == ValuationStatus.approved) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _toast(context, 'Revision request sent'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'Request a revision',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (v.status == ValuationStatus.requested ||
                  v.status == ValuationStatus.inReview)
                _PendingNote(status: v.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.status});

  final ValuationStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIconButton(
          asset: 'assets/icons/base/careleft.svg',
          onTap: () => context.pop(),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Valuation Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        StatusBadge(status: status),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.valuation});

  final Valuation valuation;

  @override
  Widget build(BuildContext context) {
    final v = valuation;
    final isLand = v.type == ValuationType.land;
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
                    v.type.asset,
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
                      v.address,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      v.province.isEmpty
                          ? v.refNo
                          : '${v.province} · ${v.refNo}',
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
          LayoutBuilder(
            builder: (context, constraints) {
              final factWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 12,
                children: [
                  _Fact(
                      label: 'Purpose',
                      value: v.purpose.label,
                      width: factWidth),
                  if (v.applicantName.isNotEmpty)
                    _Fact(
                        label: 'Applicant',
                        value: v.applicantName,
                        width: factWidth),
                  _Fact(
                    label: isLand ? 'Land size' : 'Building size',
                    value: '${isLand ? v.landSize : v.buildingSize} m²',
                    width: factWidth,
                  ),
                  if (!isLand && v.beds != null)
                    _Fact(
                        label: 'Rooms',
                        value: '${v.beds} bd · ${v.baths} ba',
                        width: factWidth),
                  if (v.photoCount > 0)
                    _Fact(
                        label: 'Photos',
                        value: '${v.photoCount} attached',
                        width: factWidth),
                  _Fact(
                      label: 'Submitted',
                      value: shortDate(v.submittedDate),
                      width: factWidth),
                  _Fact(
                    label: 'Contact',
                    value:
                        '${v.contactMethod == ContactMethod.telegram ? 'Telegram' : 'Phone'} · ${v.contactInfo}',
                    width: factWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, required this.width});

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PendingNote extends StatelessWidget {
  const _PendingNote({required this.status});

  final ValuationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/base/clock.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(status.color, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status == ValuationStatus.requested
                  ? 'We’ve received your request. A valuer will be assigned shortly.'
                  : 'A certified valuer is assessing your property. You’ll be notified when the report is ready.',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
