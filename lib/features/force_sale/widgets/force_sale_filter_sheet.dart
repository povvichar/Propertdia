import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/force_sale.dart';

/// Opens the advanced filter sheet; resolves to the applied filter (or null).
Future<ForceSaleFilter?> showForceSaleFilter(
  BuildContext context, {
  required ForceSaleFilter current,
  required List<ForceSaleProperty> all,
}) {
  return showModalBottomSheet<ForceSaleFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(current: current, all: all),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current, required this.all});

  final ForceSaleFilter current;
  final List<ForceSaleProperty> all;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _types = {...widget.current.propertyTypes};
  late int _discount = widget.current.minDiscount;
  late String _price = widget.current.priceBucket;
  late int _beds = widget.current.minBeds;

  ForceSaleFilter get _draft => ForceSaleFilter(
        propertyTypes: _types,
        minDiscount: _discount,
        priceBucket: _price,
        minBeds: _beds,
      );

  int get _count => widget.all.where(_draft.matches).length;

  void _reset() => setState(() {
        _types = {};
        _discount = 0;
        _price = 'any';
        _beds = 0;
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _reset,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                children: [
                  const _Label('Property type'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in kForceSalePropertyTypes)
                        _Chip(
                          label: t,
                          selected: _types.contains(t),
                          onTap: () => setState(() =>
                              _types.contains(t) ? _types.remove(t) : _types.add(t)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _Label('Minimum discount'),
                  _SingleRow(
                    options: const {
                      0: 'Any',
                      10: '10%+',
                      20: '20%+',
                      30: '30%+',
                    },
                    value: _discount,
                    onSelect: (v) => setState(() => _discount = v),
                  ),
                  const SizedBox(height: 20),
                  const _Label('Asking price'),
                  _SingleRow(
                    options: const {
                      'any': 'Any',
                      'lt100': '< \$100k',
                      'mid': '\$100k–300k',
                      'gt300': '> \$300k',
                    },
                    value: _price,
                    onSelect: (v) => setState(() => _price = v),
                  ),
                  const SizedBox(height: 20),
                  const _Label('Bedrooms'),
                  _SingleRow(
                    options: const {0: 'Any', 1: '1+', 2: '2+', 3: '3+', 4: '4+'},
                    value: _beds,
                    onSelect: (v) => setState(() => _beds = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: PrimaryButton(
                label: 'Show $_count result${_count == 1 ? '' : 's'}',
                trailingIcon: null,
                onPressed: () => Navigator.of(context).pop(_draft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Single-select row of chips for a `Map<value, label>`.
class _SingleRow<T> extends StatelessWidget {
  const _SingleRow({
    required this.options,
    required this.value,
    required this.onSelect,
  });

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in options.entries)
          _Chip(
            label: e.value,
            selected: e.key == value,
            onTap: () => onSelect(e.key),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
