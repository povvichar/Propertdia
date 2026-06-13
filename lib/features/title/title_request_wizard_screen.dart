import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/data/cambodia.dart';
import '../../shared/widgets/bank_select.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/map_pick_field.dart';
import '../../shared/widgets/primary_button.dart';
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
        duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
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
                    _stepDetails(),
                    _stepDocuments(),
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
        const FieldLabel('Title type'),
        ChoiceChipsRow(
          options: kTitleTypes,
          selected: _titleType,
          onSelect: (t) => setState(() => _titleType = t),
        ),
        const SizedBox(height: 18),
        const FieldLabel('Location'),
        InputField(
          controller: _address,
          hint: 'e.g. No. 12, Street 310, Sangkat …, City / Province',
          maxLines: 2,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        MapPickField(location: _location, onPick: _pickOnMap),
        const SizedBox(height: 18),
        FieldLabel(_isTransfer ? 'Current owner (seller)' : 'Applicant full name'),
        InputField(
          controller: _applicant,
          hint: 'e.g. Chan Rithy',
          onChanged: (_) => setState(() {}),
        ),
        if (_isTransfer) ...[
          const SizedBox(height: 18),
          const FieldLabel('Transfer to (buyer)'),
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
          onSelect: (v) => setState(() => _contact =
              v == 'Telegram' ? ContactWay.telegram : ContactWay.phone),
        ),
        const SizedBox(height: 14),
        InputField(
          controller: _contactInfo,
          hint: _contact == ContactWay.telegram
              ? '@username'
              : '+855 12 345 678',
          keyboardType: _contact == ContactWay.phone
              ? TextInputType.phone
              : TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
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
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _row('Service', widget.type.label),
              _row('Title type', _titleType ?? '—'),
              _row('Location', _address.text.trim()),
              if (_location != null) _row('Pinned', formatLatLng(_location!)),
              _row(_isTransfer ? 'Seller' : 'Applicant', _applicant.text.trim()),
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
