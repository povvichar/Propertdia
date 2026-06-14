import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/data/cambodia.dart';
import '../../shared/widgets/bank_select.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/map_pick_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/wizard_bottom_bar.dart';
import '../../shared/widgets/wizard_header.dart';
import 'data/title_service.dart';
import 'widgets/title_widgets.dart';

class TitleRequestWizardScreen extends StatefulWidget {
  const TitleRequestWizardScreen({super.key, required this.type});

  final TitleServiceType type;

  @override
  State<TitleRequestWizardScreen> createState() =>
      _TitleRequestWizardScreenState();
}

class _TitleRequestWizardScreenState extends State<TitleRequestWizardScreen> {
  static const _total = 3;

  final _page = PageController();
  int _step = 0;
  bool _submitted = false;

  String? _titleType;
  final _address = TextEditingController();
  LatLng? _location;
  final _applicant = TextEditingController();
  final _transferTo = TextEditingController();
  ContactWay _contact = ContactWay.telegram;
  final _contactInfo = TextEditingController();
  final _uploaded = <int>{};
  String? _bank;

  late final TitleApplication _result;

  bool get _isTransfer => widget.type == TitleServiceType.transfer;

  @override
  void dispose() {
    _page.dispose();
    _address.dispose();
    _applicant.dispose();
    _transferTo.dispose();
    _contactInfo.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_step) {
        0 => _titleType != null &&
            _address.text.trim().isNotEmpty &&
            _applicant.text.trim().isNotEmpty &&
            _contactInfo.text.trim().isNotEmpty &&
            (!_isTransfer || _transferTo.text.trim().isNotEmpty),
        1 => _uploaded.length == widget.type.requiredDocs.length,
        2 => _bank != null,
        _ => false,
      };

  String? get _validationHint {
    if (_canContinue) return null;
    return switch (_step) {
      0 => _titleType == null
          ? 'Select a title type to continue'
          : _address.text.trim().isEmpty
              ? 'Enter the property location to continue'
              : _applicant.text.trim().isEmpty
                  ? 'Enter the applicant name to continue'
                  : (_isTransfer && _transferTo.text.trim().isEmpty)
                      ? 'Enter the buyer name to continue'
                      : 'Enter your contact info to continue',
      1 => 'Upload all required documents to continue',
      2 => 'Choose a payment method to continue',
      _ => null,
    };
  }

  /// Non-blocking format hint for the contact field (does not gate the step).
  String? get _contactWarning => contactFormatWarning(
        isTelegram: _contact == ContactWay.telegram,
        value: _contactInfo.text,
      );

  Future<void> _pickOnMap() async {
    final initial = _location ?? kCambodiaCenter;
    final picked = await context.push<LatLng>('/pick-location', extra: initial);
    if (picked != null) setState(() => _location = picked);
  }

  void _next() {
    if (!_canContinue) return;
    if (_step < _total - 1) {
      setState(() => _step++);
      _page.animateToPage(_step,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic);
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
    _page.animateToPage(_step,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic);
  }

  void _submit() {
    _result = TitleApplication(
      id: 'new',
      refNo: 'TS-2026-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}',
      type: widget.type,
      status: TitleStatus.requested,
      titleType: _titleType!,
      address: _address.text.trim(),
      applicantName: _applicant.text.trim(),
      contactWay: _contact,
      contactInfo: _contactInfo.text.trim(),
      submittedDate: DateTime.now(),
      documents: widget.type.requiredDocs,
      transferTo: _isTransfer ? _transferTo.text.trim() : null,
    );
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _SuccessView(app: _result);
    }
    final lastStep = _step == _total - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
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
                    _stepDetails(),
                    _stepDocuments(),
                    _stepReview(),
                  ],
                ),
              ),
              WizardBottomBar(
                showBack: _step > 0,
                onBack: _back,
                label: lastStep ? 'Pay ${usd(widget.type.fee)}' : 'Continue',
                enabled: _canContinue,
                hint: _validationHint,
                onNext: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrap(List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: children,
      );

  Widget _stepDetails() => _wrap([
        const StepHeader(
          title: 'Property & applicant',
          subtitle: 'Tell us about the title and who is applying.',
        ),
        const SizedBox(height: 20),
        const _SubHeader('Property'),
        const SizedBox(height: 12),
        const FieldLabel('Title type', required: true),
        ChoiceChipsRow(
          options: kTitleTypes,
          selected: _titleType,
          onSelect: (t) => setState(() => _titleType = t),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hard: fully registered · Soft: provisional (commune-level) · '
          'LMAP: systematic-registration title.',
          style: TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        const FieldLabel('Location', required: true),
        InputField(
          controller: _address,
          hint: 'e.g. No. 12, Street 310, Sangkat …, City / Province',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        MapPickField(location: _location, onPick: _pickOnMap),
        const SizedBox(height: 22),
        const _SubHeader('Applicant & contact'),
        const SizedBox(height: 12),
        FieldLabel(
          _isTransfer ? 'Current owner (seller)' : 'Applicant full name',
          required: true,
        ),
        InputField(
          controller: _applicant,
          hint: 'e.g. Chan Rithy',
          onChanged: (_) => setState(() {}),
        ),
        if (_isTransfer) ...[
          const SizedBox(height: 18),
          const FieldLabel('Transfer to (buyer)', required: true),
          InputField(
            controller: _transferTo,
            hint: 'e.g. Sok Dara',
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SizedBox(height: 18),
        const FieldLabel('Contact method'),
        ChoiceChipsRow(
          options: const ['Telegram', 'Phone'],
          selected: _contact == ContactWay.telegram ? 'Telegram' : 'Phone',
          onSelect: (v) {
            final next =
                v == 'Telegram' ? ContactWay.telegram : ContactWay.phone;
            if (next != _contact) _contactInfo.clear();
            setState(() => _contact = next);
          },
        ),
        const SizedBox(height: 14),
        InputField(
          controller: _contactInfo,
          hint:
              _contact == ContactWay.telegram ? '@username' : '+855 12 345 678',
          keyboardType: _contact == ContactWay.phone
              ? TextInputType.phone
              : TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
        if (_contactWarning != null) InlineHint(_contactWarning!),
      ]);

  Widget _stepDocuments() {
    final docs = widget.type.requiredDocs;
    return _wrap([
      const StepHeader(
        title: 'Upload documents',
        subtitle: 'Attach clear scans or photos. All documents are required.',
      ),
      const SizedBox(height: 16),
      for (var i = 0; i < docs.length; i++) ...[
        DocUploadTile(
          name: docs[i],
          uploaded: _uploaded.contains(i),
          onTap: () => setState(() {
            _uploaded.contains(i) ? _uploaded.remove(i) : _uploaded.add(i);
          }),
        ),
        const SizedBox(height: 10),
      ],
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/base/locked.svg',
              width: 16,
              height: 16,
              colorFilter:
                  const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Documents are encrypted and shared only with the cadastral office.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Text(
        '${_uploaded.length} / ${docs.length} uploaded',
        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
      ),
    ]);
  }

  Widget _stepReview() => _wrap([
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
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              _row('Service', widget.type.label),
              _row('Title type', _titleType ?? '—'),
              _row('Location', _address.text.trim()),
              if (_location != null) _row('Pinned', formatLatLng(_location!)),
              _row(
                  _isTransfer ? 'Seller' : 'Applicant', _applicant.text.trim()),
              if (_isTransfer) _row('Buyer', _transferTo.text.trim()),
              _row('Documents', '${_uploaded.length} attached'),
              _row('Contact', _contactInfo.text.trim(), last: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
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
          BankTile(
            bank: b,
            selected: _bank == b.id,
            onTap: () => setState(() => _bank = b.id),
          ),
          const SizedBox(height: 10),
        ],
      ]);

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

/// Small uppercase section label used to group fields within a wizard step.
class _SubHeader extends StatelessWidget {
  const _SubHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.6,
      ),
    );
  }
}

// ── Success ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.app});

  final TitleApplication app;

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
                  'Application submitted',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ${app.type.label.toLowerCase()} request is now being processed. We’ll notify you of every status update.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                        app.refNo,
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
                  onPressed: () =>
                      context.pushReplacement('/title/detail', extra: app),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Back to Title Services',
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
