import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/data/cambodia.dart';
import '../../shared/widgets/bank_select.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/map_pick_field.dart';
import '../../shared/widgets/photo_gallery.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/wizard_bottom_bar.dart';
import '../../shared/widgets/wizard_header.dart';
import '../../shared/widgets/payment_sheet.dart';
import 'data/pricing.dart';
import 'data/valuation.dart';
import 'widgets/estimate_widgets.dart';

class ValuationWizardScreen extends StatefulWidget {
  const ValuationWizardScreen({super.key, required this.type, this.prefill});

  final ValuationType type;

  /// Inputs carried over from the free Instant Estimate, if the user arrived
  /// from there. When null this is a fresh request.
  final EstimatePrefill? prefill;

  @override
  State<ValuationWizardScreen> createState() => _ValuationWizardScreenState();
}

class _ValuationWizardScreenState extends State<ValuationWizardScreen> {
  static const _total = 4;

  static const _galleryPool = [
    'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=300&q=80',
    'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=300&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=300&q=80',
    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&q=80',
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=300&q=80',
    'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=300&q=80',
    'https://images.unsplash.com/photo-1565182999561-18d7dc61c393?w=300&q=80',
    'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=300&q=80',
  ];

  final _page = PageController();
  int _step = 0;
  bool _submitted = false;

  // Draft fields
  LatLng? _location;
  final _address = TextEditingController();
  String? _province;
  final _size = TextEditingController();
  String? _landTitle;
  String? _buildingType;
  int _beds = 2;
  int _baths = 2;
  final _photos = <String>[];
  final _name = TextEditingController();
  final _contactInfo = TextEditingController();
  final _contactInfo2 = TextEditingController();
  String? _bank;
  ValuationPurpose _purpose = ValuationPurpose.sale;
  late final Valuation _result;

  @override
  void initState() {
    super.initState();
    // Carry over anything the user already entered in the Instant Estimate.
    final pf = widget.prefill;
    if (pf != null) {
      _province = pf.province;
      _buildingType = pf.propertyType;
      _landTitle = pf.landTitle;
      if (pf.size != null) _size.text = pf.size!;
      if (pf.beds != null) _beds = pf.beds!;
      if (pf.baths != null) _baths = pf.baths!;
      if (pf.purpose != null) _purpose = pf.purpose!;
    }
  }

  @override
  void dispose() {
    _page.dispose();
    _address.dispose();
    _size.dispose();
    _name.dispose();
    _contactInfo.dispose();
    _contactInfo2.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_step) {
        0 => _address.text.trim().isNotEmpty && _province != null,
        1 => _size.text.trim().isNotEmpty &&
            (widget.type != ValuationType.land || _landTitle != null) &&
            (widget.type != ValuationType.building || _buildingType != null),
        2 => _name.text.trim().isNotEmpty &&
            _contactInfo.text.trim().isNotEmpty,
        3 => _bank != null,
        _ => false,
      };

  String? get _validationHint {
    if (_canContinue) return null;
    return switch (_step) {
      0 => _address.text.trim().isEmpty
          ? 'Enter a property address to continue'
          : _province == null
              ? 'Select a province to continue'
              : null,
      1 => _size.text.trim().isEmpty
          ? 'Enter the property size to continue'
          : (widget.type == ValuationType.land && _landTitle == null)
              ? 'Select a land title type to continue'
              : (widget.type == ValuationType.building && _buildingType == null)
                  ? 'Select a property type to continue'
                  : null,
      2 => _name.text.trim().isEmpty
          ? 'Enter your name to continue'
          : 'Enter your contact info to continue',
      3 => 'Choose a payment method to continue',
      _ => null,
    };
  }

  /// Indicative estimate from the current inputs, or null if not enough data.
  EstimateResult? get _estimate {
    final size = double.tryParse(_size.text.trim());
    if (_province == null || size == null || size <= 0) return null;
    final isLand = widget.type == ValuationType.land;
    if (isLand ? _landTitle == null : _buildingType == null) return null;
    return estimateValue(
      type: widget.type,
      province: _province!,
      propertyType: isLand ? 'Land' : _buildingType!,
      sizeSqm: size,
      beds: isLand ? null : _beds,
      baths: isLand ? null : _baths,
      landTitle: isLand ? _landTitle : null,
      purpose: _purpose,
    );
  }

  Future<void> _pickOnMap() async {
    final initial = _location ?? kCambodiaCenter;
    final picked = await context.push<LatLng>('/pick-location', extra: initial);
    if (picked != null) setState(() => _location = picked);
  }

  void _next() {
    if (!_canContinue) return;
    if (_step < _total - 1) {
      setState(() => _step++);
      _page.animateToPage(
        _step,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      final bank = kBanks.firstWhere((b) => b.id == _bank);
      showPaymentSheet(
        context,
        bank: bank,
        amountUsd: _quote.total,
        onSuccess: _submit,
      );
    }
  }

  void _back() {
    if (_step == 0) {
      context.pop();
      return;
    }
    setState(() => _step--);
    _page.animateToPage(
      _step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _submit() {
    final isLand = widget.type == ValuationType.land;
    final est = _estimate;
    final refNo = 'VL-2026-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}';
    _result = Valuation(
      id: refNo,
      refNo: refNo,
      type: widget.type,
      status: ValuationStatus.requested,
      address: _address.text.trim(),
      province: _province ?? '',
      applicantName: _name.text.trim(),
      lat: _location?.latitude,
      lng: _location?.longitude,
      purpose: _purpose,
      propertyType: isLand ? 'Land' : (_buildingType ?? 'Building'),
      contactInfo: _contactInfo2.text.trim().isEmpty
          ? _contactInfo.text.trim()
          : '${_contactInfo.text.trim()} · ${_contactInfo2.text.trim()}',
      submittedDate: DateTime.now(),
      landSize: isLand ? _size.text.trim() : null,
      buildingSize: isLand ? null : _size.text.trim(),
      beds: isLand ? null : _beds,
      baths: isLand ? null : _baths,
      // Indicative figure attached immediately; a valuer certifies it later.
      estimatedValue: est?.value,
      valueLow: est?.low,
      valueHigh: est?.high,
      comparables: est?.comparables ?? 0,
      photoCount: _photos.length,
    );
    valuationStore.add(_result);
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _SuccessView(valuation: _result, fee: _quote.total);
    }

    final lastStep = _step == _total - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  WizardHeader(
                    title: widget.type.label,
                    step: _step,
                    total: _total,
                    onBack: _back,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _page,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _stepLocation(),
                        _stepDetails(),
                        _stepPhotosContact(),
                        _stepReview(),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: WizardBottomBar(
                  showBack: _step > 0,
                  onBack: _back,
                  label: lastStep ? 'Pay ${usd(_quote.total)}' : 'Continue',
                  enabled: _canContinue,
                  hint: _validationHint,
                  onNext: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Steps ──────────────────────────────────────────────────────────────

  Widget _wrap(List<Widget> children) => ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 160 + MediaQuery.paddingOf(context).bottom),
        children: children,
      );

  Widget _stepLocation() => _wrap([
        const StepHeader(
          title: 'Where is the property?',
          subtitle: 'Enter the location and pin it on the map.',
        ),
        const SizedBox(height: 20),
        const FieldLabel('Location', required: true),
        InputField(
          controller: _address,
          hint: 'e.g. No. 12, Street 310, Sangkat …',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const FieldLabel('Province / city', required: true),
        SelectField(
          value: _province,
          hint: 'Select a province',
          sheetTitle: 'Province / city',
          options: kCambodiaProvinces,
          onSelect: (v) => setState(() => _province = v),
        ),
        const SizedBox(height: 14),
        MapPickField(location: _location, onPick: _pickOnMap),
        const SizedBox(height: 18),
        const FieldLabel('Valuation purpose'),
        for (final p in ValuationPurpose.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionTile(
              label: p.label,
              asset: p.asset,
              selected: _purpose == p,
              onTap: () => setState(() => _purpose = p),
            ),
          ),
      ]);

  Widget _stepDetails() {
    final isLand = widget.type == ValuationType.land;
    return _wrap([
      StepHeader(
        title: isLand ? 'Land details' : 'Building details',
        subtitle: 'Provide the measurements and key attributes.',
      ),
      const SizedBox(height: 20),
      FieldLabel(isLand ? 'Land size' : 'Building size', required: true),
      InputField(
        controller: _size,
        hint: 'e.g. 320',
        suffix: 'm²',
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 18),
      if (isLand) ...[
        const FieldLabel('Land title type', required: true),
        ChoiceChipsRow(
          options: kLandTitles,
          selected: _landTitle,
          onSelect: (t) => setState(() => _landTitle = t),
        ),
      ] else ...[
        const FieldLabel('Property type', required: true),
        ChoiceChipsRow(
          options: const ['Villa', 'Condo', 'Apartment', 'Shophouse', 'Townhouse'],
          selected: _buildingType,
          onSelect: (t) => setState(() => _buildingType = t),
        ),
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
    ]);
  }

  Widget _stepPhotosContact() => _wrap([
        const StepHeader(
          title: 'Photos & contact',
          subtitle: 'Add photos for the valuer and tell us how to reach you.',
        ),
        const SizedBox(height: 20),
        const FieldLabel('Property photos'),
        PhotoGalleryField(
          photos: _photos,
          onAdd: () => setState(
              () => _photos.add(_galleryPool[_photos.length % _galleryPool.length])),
          onRemoveAt: (i) => setState(() => _photos.removeAt(i)),
        ),
        const SizedBox(height: 8),
        Text(
          '${_photos.length} photo${_photos.length == 1 ? '' : 's'} added',
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        const FieldLabel('Your name', required: true),
        InputField(
          controller: _name,
          hint: 'e.g. Chan Rithy',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        const FieldLabel('Phone number', required: true),
        InputField(
          controller: _contactInfo,
          hint: '+855 12 345 678',
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const FieldLabel('Other phone number'),
        InputField(
          controller: _contactInfo2,
          hint: '+855 99 888 777',
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
        ),
      ]);

  /// Computed hybrid fee from the entered size, province & purpose.
  ValuationQuote get _quote => valuationQuote(
        type: widget.type,
        areaSqm: double.tryParse(_size.text.trim()),
        province: _province,
        purpose: _purpose,
      );

  Widget _stepReview() {
    final isLand = widget.type == ValuationType.land;
    final est = _estimate;
    final q = _quote;
    return _wrap([
      const StepHeader(
        title: 'Review & payment',
        subtitle: 'Confirm the details and choose a payment method.',
      ),
      if (est != null) ...[
        const SizedBox(height: 18),
        EstimateRangeCard(
          value: est.value,
          low: est.low,
          high: est.high,
          comparables: est.comparables,
          basis: est.basis,
        ),
        const SizedBox(height: 8),
        const Text(
          'A certified valuer will confirm this figure in your report.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            _row('Type', widget.type.label),
            _row('Purpose', _purpose.label),
            _row('Location', _address.text.trim()),
            if (_location != null) _row('Pinned', formatLatLng(_location!)),
            _row(isLand ? 'Land size' : 'Building size', '${_size.text} m²'),
            if (isLand && _landTitle != null) _row('Title', _landTitle!),
            if (!isLand) _row('Property', _buildingType ?? '—'),
            if (!isLand) _row('Rooms', '$_beds bd · $_baths ba'),
            _row('Photos', '${_photos.length} added'),
            _row('Applicant', _name.text.trim()),
            _row('Contact', _contactInfo.text.trim(), last: true),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Fee breakdown (base + size + location + certified report)
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            _feeRow('Base ${widget.type.short.toLowerCase()} valuation',
                usd(q.base)),
            if (q.sizeAddon > 0)
              _feeRow('Size · ${_size.text.trim()} m²', '+ ${usd(q.sizeAddon)}'),
            if (q.locationAddon > 0)
              _feeRow('Site visit · ${_province ?? ''}',
                  '+ ${usd(q.locationAddon)}'),
            if (q.certifiedAddon > 0)
              _feeRow('Certified report · ${_purpose.label}',
                  '+ ${usd(q.certifiedAddon)}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child:
                  Divider(height: 1, thickness: 1, color: AppColors.divider),
            ),
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  usd(q.total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const FieldLabel('Payment method'),
      for (final b in kBanks) ...[
        BankTile(
          bank: b,
          selected: _bank == b.id,
          onTap: () => setState(() => _bank = b.id),
        ),
        const SizedBox(height: 10),
      ],
    ]);
  }

  Widget _feeRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            v,
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

  Widget _row(String k, String v, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              k,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '—' : v,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.valuation, required this.fee});

  final Valuation valuation;
  final int fee;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 36, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment successful',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ${valuation.type.label.toLowerCase()} request has been submitted. We’ll review it within 3–5 business days.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Reference',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        valuation.refNo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Certified report expected by ${shortDate(addBusinessDays(valuation.submittedDate, 5))}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Track status',
                  trailingIcon: null,
                  onPressed: () => context.pushReplacement(
                    '/estimate/detail',
                    extra: valuation,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Back to Estimate',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
