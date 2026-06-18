import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Search field + standalone filter button (Force Sale style): a white search
/// pill on the left and a navy square sliders button on the right that shows a
/// gold dot when a filter is active. Reused by hub history list screens.
class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.filterActive,
    this.onFilter,
    this.hint = 'Search',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool filterActive;
  final VoidCallback? onFilter;
  final String hint;

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: _focused
                  ? Border.all(color: AppColors.gold, width: 1.5)
                  : null,
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/base/search.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    _focused ? AppColors.gold : AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    focusNode: _focus,
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: widget.onFilter,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/icons/base/slidershorizontal.svg',
                    width: 20,
                    height: 20,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                if (widget.filterActive)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navy, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Removable chip showing an active filter selection (colored dot + label + ✕).
class ActiveFilterChip extends StatelessWidget {
  const ActiveFilterChip({
    super.key,
    required this.label,
    required this.color,
    required this.onClear,
  });

  final String label;
  final Color color;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClear,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 7, 5),
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.close_rounded,
                size: 15, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// One option in [showStatusFilterSheet].
class StatusFilterOption {
  const StatusFilterOption({
    required this.label,
    required this.color,
    required this.count,
    required this.selected,
  });

  final String label;
  final Color color;
  final int count;
  final bool selected;
}

/// Generic status filter bottom sheet (colored marker + count per option).
/// Invokes [onSelect] with the chosen option's index, then closes.
Future<void> showStatusFilterSheet(
  BuildContext context, {
  String title = 'Filter by status',
  required List<StatusFilterOption> options,
  required ValueChanged<int> onSelect,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => _StatusFilterSheet(
      title: title,
      options: options,
      onSelect: (i) {
        onSelect(i);
        Navigator.of(sheetCtx).pop();
      },
    ),
  );
}

class _StatusFilterSheet extends StatelessWidget {
  const _StatusFilterSheet({
    required this.title,
    required this.options,
    required this.onSelect,
  });

  final String title;
  final List<StatusFilterOption> options;
  final ValueChanged<int> onSelect;

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
            for (var i = 0; i < options.length; i++)
              _FilterRow(option: options[i], onTap: () => onSelect(i)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.option, required this.onTap});

  final StatusFilterOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: option.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      option.selected ? FontWeight.w800 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${option.count}',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 18,
              child: option.selected
                  ? SvgPicture.asset(
                      'assets/icons/base/check.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                          AppColors.gold, BlendMode.srcIn),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
