import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../auth/data/account.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/primary_button.dart';
import 'data/invest.dart';
import 'widgets/invest_sheets.dart';
import 'widgets/invest_widgets.dart';

/// Real-world style membership application. Collects identity + a financial
/// profile; the investable-assets band sets the starting investor tier once an
/// admin approves the request.
class InvestorApplicationScreen extends StatefulWidget {
  const InvestorApplicationScreen({super.key});

  @override
  State<InvestorApplicationScreen> createState() =>
      _InvestorApplicationScreenState();
}

class _InvestorApplicationScreenState extends State<InvestorApplicationScreen> {
  late final TextEditingController _name =
      TextEditingController(text: session.current?.name ?? '');
  final _id = TextEditingController();
  final _commitment = TextEditingController();

  String? _income;
  String? _assets;
  String? _experience;
  String? _source;
  bool _risk = false;

  @override
  void dispose() {
    _name.dispose();
    _id.dispose();
    _commitment.dispose();
    super.dispose();
  }

  int get _commitmentValue => int.tryParse(_commitment.text) ?? 0;

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _id.text.trim().isNotEmpty &&
      _income != null &&
      _assets != null &&
      _experience != null &&
      _source != null &&
      _commitmentValue > 0 &&
      _risk;

  void _submit() {
    if (!_valid) return;
    investStore.requestMembership(InvestorApplication(
      legalName: _name.text.trim(),
      idNumber: _id.text.trim(),
      annualIncome: _income!,
      investableAssets: _assets!,
      experience: _experience!,
      sourceOfFunds: _source!,
      intendedCommitment: _commitmentValue,
      riskAccepted: _risk,
      submittedAt: DateTime.now(),
    ));
    context.pop();
    investToast(context, 'Application submitted — under review');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: InvestTopBar(
                  title: 'Investor Application',
                  onBack: () => context.pop(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    const StepHeader(
                      title: 'Apply for membership',
                      subtitle:
                          'Tell us about yourself. Our team reviews every '
                          'application before activating your investor wallet.',
                    ),
                    const SizedBox(height: 24),
                    const FieldLabel('Full legal name', required: true),
                    InputField(
                      controller: _name,
                      hint: 'As shown on your ID',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('National ID / Passport no.',
                        required: true),
                    InputField(
                      controller: _id,
                      hint: 'e.g. 012345678',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    const FieldLabel('Annual income', required: true),
                    ChoiceChipsRow(
                      options: kIncomeBands,
                      selected: _income,
                      onSelect: (v) => setState(() => _income = v),
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Investable assets', required: true),
                    ChoiceChipsRow(
                      options: kAssetBands,
                      selected: _assets,
                      onSelect: (v) => setState(() => _assets = v),
                    ),
                    if (_assets != null)
                      InlineHint(
                        'Starting tier: ${tierForAssetBand(_assets!).label}. '
                        'You climb further as you invest.',
                      ),
                    const SizedBox(height: 18),
                    const FieldLabel('Investment experience', required: true),
                    ChoiceChipsRow(
                      options: kExperienceLevels,
                      selected: _experience,
                      onSelect: (v) => setState(() => _experience = v),
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Source of funds', required: true),
                    ChoiceChipsRow(
                      options: kFundSources,
                      selected: _source,
                      onSelect: (v) => setState(() => _source = v),
                    ),
                    const SizedBox(height: 22),
                    const FieldLabel('Intended initial commitment',
                        required: true),
                    InputField(
                      controller: _commitment,
                      hint: '5000',
                      suffix: 'USD',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    OptionTile(
                      label: 'I understand the risks',
                      subtitle:
                          'Property investments carry risk and may lose value.',
                      selected: _risk,
                      onTap: () => setState(() => _risk = !_risk),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Submit application',
                      trailingIcon: null,
                      enabled: _valid,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Reviewed by our team · approved within 24h',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
