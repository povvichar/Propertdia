import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/list_filter.dart';
import 'data/valuation.dart';
import 'widgets/estimate_widgets.dart';

/// Full, searchable & filterable list of the user's valuation requests —
/// the "See all" destination from the Estimate hub.
class ValuationsScreen extends StatefulWidget {
  const ValuationsScreen({super.key});

  @override
  State<ValuationsScreen> createState() => _ValuationsScreenState();
}

class _ValuationsScreenState extends State<ValuationsScreen> {
  ValuationStatus? _filter;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
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
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.navy),
            ),
          ),
          title: const Text(
            'My Valuations',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: valuationStore,
            builder: (context, _) {
              final all = [...valuationStore.items]
                ..sort((a, b) => b.submittedDate.compareTo(a.submittedDate));
              final q = _query.trim().toLowerCase();
              final filtered = all.where((v) {
                if (_filter != null && v.status != _filter) return false;
                if (q.isEmpty) return true;
                return v.refNo.toLowerCase().contains(q) ||
                    v.address.toLowerCase().contains(q) ||
                    v.propertyType.toLowerCase().contains(q) ||
                    v.applicantName.toLowerCase().contains(q) ||
                    v.province.toLowerCase().contains(q) ||
                    v.type.label.toLowerCase().contains(q);
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SearchFilterBar(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      hint: 'Search ref no, address, type…',
                      filterActive: _filter != null,
                      onFilter: all.isEmpty
                          ? null
                          : () => showValuationStatusFilter(
                                context,
                                selected: _filter,
                                items: all,
                                onSelect: (s) => setState(() => _filter = s),
                              ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} valuation${filtered.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (_filter != null)
                          ActiveFilterChip(
                            label: _filter!.label,
                            color: _filter!.color,
                            onClear: () => setState(() => _filter = null),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? _EmptyState(
                            title:
                                all.isEmpty ? 'No valuations yet' : 'No matches',
                            blurb: all.isEmpty
                                ? 'Request a valuation from the Estimate screen.'
                                : 'Try a different search or status filter.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                ValuationCard(valuation: filtered[i]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.blurb});

  final String title;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.iconTile,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/base/scale.svg',
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                      AppColors.navyIcon, BlendMode.srcIn),
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
      ),
    );
  }
}
