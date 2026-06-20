import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/module_hero_sliver.dart';
import 'data/eligibility.dart';

/// Free, instant ownership-eligibility checker. Applies Cambodian
/// foreign-ownership rules (land vs. strata, the 70% cap, ground-floor rule)
/// and surfaces lawful alternatives. Educational — no payment, no submission.
class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  Nationality? _who;
  AcquiringKind? _kind;
  bool _groundFloor = false;

  bool get _foreignStrata =>
      _who == Nationality.foreign && _kind == AcquiringKind.strataUnit;

  EligibilityResult? get _result {
    if (_who == null || _kind == null) return null;
    return checkEligibility(
      who: _who!,
      kind: _kind!,
      groundFloor: _foreignStrata && _groundFloor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            const ModuleHeroSliver(
              title: 'Ownership Eligibility',
              headline: 'Can you own this property?',
              subtitle:
                  'Free check · Cambodian foreign-ownership rules explained',
              icon: 'assets/icons/base/shield_user.svg',
              iconSize: 150,
              iconTop: 12,
              iconRight: -18,
            ),
            ModuleHeroSheet(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Buyer nationality', required: true),
                  ChoiceChipsRow(
                    options: const ['Cambodian', 'Foreign'],
                    selected: _who == null
                        ? null
                        : (_who == Nationality.cambodian
                            ? 'Cambodian'
                            : 'Foreign'),
                    onSelect: (v) => setState(() => _who = v == 'Cambodian'
                        ? Nationality.cambodian
                        : Nationality.foreign),
                  ),
                  const SizedBox(height: 18),
                  const FieldLabel('What are you acquiring?', required: true),
                  for (final k in AcquiringKind.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OptionTile(
                        label: k.label,
                        selected: _kind == k,
                        onTap: () => setState(() => _kind = k),
                      ),
                    ),
                  if (_foreignStrata) ...[
                    const SizedBox(height: 10),
                    const FieldLabel('Which floor?'),
                    ChoiceChipsRow(
                      options: const ['1st floor or above', 'Ground floor'],
                      selected:
                          _groundFloor ? 'Ground floor' : '1st floor or above',
                      onSelect: (v) =>
                          setState(() => _groundFloor = v == 'Ground floor'),
                    ),
                  ],
                  const SizedBox(height: 22),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SizeTransition(sizeFactor: anim, child: child),
                    ),
                    child: result == null
                        ? const _Prompt(key: ValueKey('prompt'))
                        : _EligibilityCard(
                            key: const ValueKey('result'), result: result),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'General guidance only — not legal advice. Confirm with a '
                    'licensed Cambodian lawyer before transacting.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EligibilityCard extends StatelessWidget {
  const _EligibilityCard({super.key, required this.result});

  final EligibilityResult result;

  @override
  Widget build(BuildContext context) {
    final c = result.verdict.color;
    return Container(
      width: double.infinity,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  result.verdict.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.headline,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          for (final p in result.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (result.note != null) ...[
            const SizedBox(height: 4),
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
                      result.note!,
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

class _Prompt extends StatelessWidget {
  const _Prompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.gavel_rounded,
              size: 26, color: AppColors.textSecondary.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
          const Text(
            'Choose nationality and property type to check eligibility.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
