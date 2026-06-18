import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/data/cambodia.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/module_hero_sliver.dart';
import '../../shared/widgets/primary_button.dart';
import 'data/pricing.dart';
import 'data/valuation.dart';
import 'widgets/estimate_widgets.dart';

/// Free, instant property-value estimator. Computes a `$/m²`-based indicative
/// range on the spot (no payment, no submission) and offers to escalate into
/// the paid Professional Valuation wizard with the inputs pre-filled.
class InstantEstimateScreen extends StatefulWidget {
  const InstantEstimateScreen({super.key});

  @override
  State<InstantEstimateScreen> createState() => _InstantEstimateScreenState();
}

class _InstantEstimateScreenState extends State<InstantEstimateScreen> {
  static const _buildingTypes = [
    'Villa',
    'Condo',
    'Apartment',
    'Shophouse',
    'Townhouse',
  ];

  ValuationType _type = ValuationType.building;
  String? _province;
  String? _buildingType;
  String? _landTitle;
  final _size = TextEditingController();
  int _beds = 2;
  int _baths = 2;

  @override
  void dispose() {
    _size.dispose();
    super.dispose();
  }

  bool get _isLand => _type == ValuationType.land;

  double? get _sizeValue {
    final v = double.tryParse(_size.text.trim());
    return (v != null && v > 0) ? v : null;
  }

  /// Enough inputs to produce a figure.
  bool get _canEstimate {
    if (_province == null || _sizeValue == null) return false;
    return _isLand ? _landTitle != null : _buildingType != null;
  }

  EstimateResult? get _result {
    if (!_canEstimate) return null;
    return estimateValue(
      type: _type,
      province: _province!,
      propertyType: _isLand ? 'Land' : _buildingType!,
      sizeSqm: _sizeValue!,
      beds: _beds,
      baths: _baths,
      landTitle: _landTitle,
    );
  }

  void _setType(ValuationType t) {
    setState(() {
      _type = t;
      // Clear the type-specific selection so a stale value can't leak across.
      _buildingType = null;
      _landTitle = null;
    });
  }

  void _toProfessional() {
    context.push(
      '/estimate/new',
      extra: EstimatePrefill(
        type: _type,
        province: _province,
        propertyType: _isLand ? null : _buildingType,
        size: _size.text.trim().isEmpty ? null : _size.text.trim(),
        beds: _isLand ? null : _beds,
        baths: _isLand ? null : _baths,
        landTitle: _isLand ? _landTitle : null,
      ),
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
              title: 'Instant Estimate',
              headline: 'What is your property worth?',
              subtitle:
                  'Free instant guide price · based on local \$/m² market data',
              icon: 'assets/icons/base/scale.svg',
              iconSize: 168,
              iconTop: 22,
              iconRight: -28,
            ),
            ModuleHeroSheet(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('Property type', required: true),
                  ChoiceChipsRow(
                    options: const ['Building', 'Land'],
                    selected: _isLand ? 'Land' : 'Building',
                    onSelect: (v) => _setType(
                        v == 'Land' ? ValuationType.land : ValuationType.building),
                  ),
                  const SizedBox(height: 18),
                  const FieldLabel('Province / city', required: true),
                  SelectField(
                    value: _province,
                    hint: 'Select a province',
                    sheetTitle: 'Province / city',
                    options: kCambodiaProvinces,
                    onSelect: (v) => setState(() => _province = v),
                  ),
                  const SizedBox(height: 18),
                  if (_isLand) ...[
                    const FieldLabel('Land title type', required: true),
                    ChoiceChipsRow(
                      options: kLandTitles,
                      selected: _landTitle,
                      onSelect: (t) => setState(() => _landTitle = t),
                    ),
                  ] else ...[
                    const FieldLabel('Building type', required: true),
                    ChoiceChipsRow(
                      options: _buildingTypes,
                      selected: _buildingType,
                      onSelect: (t) => setState(() => _buildingType = t),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FieldLabel(_isLand ? 'Land size' : 'Building size',
                      required: true),
                  InputField(
                    controller: _size,
                    hint: 'e.g. 320',
                    suffix: 'm²',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  if (!_isLand) ...[
                    const SizedBox(height: 18),
                    const FieldLabel('Rooms'),
                    CounterField(
                      label: 'Bedrooms',
                      asset: 'assets/icons/base/bed.svg',
                      value: _beds,
                      onChanged: (v) => setState(() => _beds = v),
                    ),
                    const SizedBox(height: 10),
                    CounterField(
                      label: 'Bathrooms',
                      asset: 'assets/icons/base/bath.svg',
                      value: _baths,
                      onChanged: (v) => setState(() => _baths = v),
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
                        ? const _EstimatePrompt(key: ValueKey('prompt'))
                        : Column(
                            key: const ValueKey('result'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EstimateRangeCard(
                                value: result.value,
                                low: result.low,
                                high: result.high,
                                comparables: result.comparables,
                                basis: result.basis,
                              ),
                              const SizedBox(height: 16),
                              PrimaryButton(
                                label: 'Get a certified valuation',
                                trailingIcon:
                                    'assets/icons/base/arrowright.svg',
                                onPressed: _toProfessional,
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'A certified valuer confirms the figure with a signed report.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ],
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

/// Shown before there's enough input to compute a figure.
class _EstimatePrompt extends StatelessWidget {
  const _EstimatePrompt({super.key});

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
          Icon(Icons.insights_rounded,
              size: 28, color: AppColors.textSecondary.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
          const Text(
            'Fill in the details above to see an instant estimate.',
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
