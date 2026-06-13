import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/primary_button.dart';
import 'data/valuation.dart';
import 'widgets/form_fields.dart';

class ValuationWizardScreen extends StatefulWidget {
  const ValuationWizardScreen({super.key, required this.type});

  final ValuationType type;

  @override
  State<ValuationWizardScreen> createState() => _ValuationWizardScreenState();
}

class _ValuationWizardScreenState extends State<ValuationWizardScreen> {
  static const _total = 3;

  final _page = PageController();
  int _step = 0;
  bool _submitted = false;

  // Draft fields
  final _address = TextEditingController();
  String? _district;
  final _size = TextEditingController();
  String? _landTitle;
  String? _buildingType;
  int _beds = 2;
  int _baths = 2;
  ContactMethod _contact = ContactMethod.telegram;
  final _contactInfo = TextEditingController();
  String? _bank;

  late final Valuation _result;

  @override
  void dispose() {
    _page.dispose();
    _address.dispose();
    _size.dispose();
    _contactInfo.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_step) {
        0 => _address.text.trim().isNotEmpty &&
            _district != null &&
            _size.text.trim().isNotEmpty,
        1 => _contactInfo.text.trim().isNotEmpty,
        2 => _bank != null,
        _ => false,
      };

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
      _submit();
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
    _result = Valuation(
      id: 'new',
      refNo: 'VL-2026-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}',
      type: widget.type,
      status: ValuationStatus.requested,
      address: _address.text.trim(),
      district: _district!,
      purpose: ValuationPurpose.sale,
      propertyType: isLand ? 'Land' : (_buildingType ?? 'Villa'),
      contactMethod: _contact,
      contactInfo: _contactInfo.text.trim(),
      submittedDate: DateTime.now(),
      landSize: isLand ? _size.text.trim() : null,
      buildingSize: isLand ? null : _size.text.trim(),
      beds: isLand ? null : _beds,
      baths: isLand ? null : _baths,
    );
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _SuccessView(valuation: _result, fee: widget.type.fee);
    }

    final lastStep = _step == _total - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _WizardHeader(
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
                    _stepProperty(),
                    _stepContact(),
                    _stepReview(),
                  ],
                ),
              ),
              _BottomBar(
                showBack: _step > 0,
                onBack: _back,
                label: lastStep ? 'Pay ${usd(widget.type.fee)}' : 'Continue',
                enabled: _canContinue,
                onNext: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Steps ──────────────────────────────────────────────────────────────

  Widget _wrap(List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: children,
      );

  Widget _stepProperty() {
    final isLand = widget.type == ValuationType.land;
    return _wrap([
      const StepHeader(
        title: 'Tell us about the property',
        subtitle: 'Address, size and a few key details.',
      ),
      const SizedBox(height: 20),
      const FieldLabel('Street address'),
      InputField(
        controller: _address,
        hint: 'e.g. No. 12, Street 310',
        maxLines: 2,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 18),
      const FieldLabel('District'),
      ChoiceChipsRow(
        options: kDistricts,
        selected: _district,
        onSelect: (d) => setState(() => _district = d),
      ),
      const SizedBox(height: 18),
      FieldLabel(isLand ? 'Land size' : 'Building size'),
      InputField(
        controller: _size,
        hint: 'e.g. 320',
        suffix: 'm²',
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 18),
      if (isLand) ...[
        const FieldLabel('Land title type'),
        ChoiceChipsRow(
          options: kLandTitles,
          selected: _landTitle,
          onSelect: (t) => setState(() => _landTitle = t),
        ),
      ] else ...[
        const FieldLabel('Property type'),
        ChoiceChipsRow(
          options: const ['Villa', 'Condo', 'Apartment', 'Shophouse', 'Townhouse'],
          selected: _buildingType,
          onSelect: (t) => setState(() => _buildingType = t),
        ),
        const SizedBox(height: 18),
        const FieldLabel('Rooms'),
        CounterField(
          label: 'Bedrooms',
          value: _beds,
          onChanged: (v) => setState(() => _beds = v),
        ),
        const SizedBox(height: 10),
        CounterField(
          label: 'Bathrooms',
          value: _baths,
          onChanged: (v) => setState(() => _baths = v),
        ),
      ],
    ]);
  }

  Widget _stepContact() => _wrap([
        const StepHeader(
          title: 'How can the valuer reach you?',
          subtitle: 'We may contact you to schedule a site visit.',
        ),
        const SizedBox(height: 20),
        OptionTile(
          label: 'Telegram',
          asset: 'assets/icons/base/telegram.svg',
          selected: _contact == ContactMethod.telegram,
          onTap: () => setState(() => _contact = ContactMethod.telegram),
        ),
        const SizedBox(height: 10),
        OptionTile(
          label: 'Phone call',
          asset: 'assets/icons/base/phone.svg',
          selected: _contact == ContactMethod.phone,
          onTap: () => setState(() => _contact = ContactMethod.phone),
        ),
        const SizedBox(height: 18),
        FieldLabel(_contact == ContactMethod.telegram
            ? 'Telegram username'
            : 'Phone number'),
        InputField(
          controller: _contactInfo,
          hint: _contact == ContactMethod.telegram
              ? '@username'
              : '+855 12 345 678',
          keyboardType: _contact == ContactMethod.phone
              ? TextInputType.phone
              : TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
      ]);

  Widget _stepReview() {
    final isLand = widget.type == ValuationType.land;
    return _wrap([
      const StepHeader(
        title: 'Review & payment',
        subtitle: 'Confirm the details and choose a payment method.',
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            _row('Type', widget.type.label),
            _row('Address', _address.text.trim()),
            _row('District', _district ?? '—'),
            _row(isLand ? 'Land size' : 'Building size', '${_size.text} m²'),
            if (isLand && _landTitle != null) _row('Title', _landTitle!),
            if (!isLand) _row('Property', _buildingType ?? 'Villa'),
            if (!isLand) _row('Rooms', '$_beds bd · $_baths ba'),
            _row('Contact', _contactInfo.text.trim(), last: true),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Fee summary
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text(
              'Service fee',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              usd(widget.type.fee),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const FieldLabel('Payment method'),
      for (final b in kBanks) ...[
        _BankTile(
          bank: b,
          selected: _bank == b.id,
          onTap: () => setState(() => _bank = b.id),
        ),
        const SizedBox(height: 10),
      ],
    ]);
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

// ── Header & bottom bar ──────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({
    required this.title,
    required this.step,
    required this.total,
    required this.onBack,
  });

  final String title;
  final int step;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              GlassIconButton(
                asset: 'assets/icons/base/caretright.svg',
                onTap: onBack,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Text(
                'Step ${step + 1}/$total',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 5,
                    decoration: BoxDecoration(
                      color: i <= step ? AppColors.gold : AppColors.iconTile,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (i < total - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.showBack,
    required this.onBack,
    required this.label,
    required this.enabled,
    required this.onNext,
  });

  final bool showBack;
  final VoidCallback onBack;
  final String label;
  final bool enabled;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                height: 48,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/base/caretright.svg',
                    width: 18,
                    height: 18,
                    colorFilter:
                        const ColorFilter.mode(AppColors.navy, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: PrimaryButton(
              label: label,
              enabled: enabled,
              onPressed: enabled ? onNext : () {},
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tiles ────────────────────────────────────────────────────────────────

class _BankTile extends StatelessWidget {
  const _BankTile({
    required this.bank,
    required this.selected,
    required this.onTap,
  });

  final BankOption bank;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bank.logoBg,
                borderRadius: BorderRadius.circular(12),
                border: bank.logoBg == Colors.white
                    ? Border.all(color: AppColors.border)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: SvgPicture.asset(
                  bank.logoAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bank.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.gold : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
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
                    color: const Color(0xFF0F973D).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F973D),
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
