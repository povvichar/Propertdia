import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/form_fields.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/social_auth.dart';
import '../invest/data/invest.dart';
import 'data/account.dart';

/// Three-step sign-up wizard: phone number → (mocked) OTP → profile.
/// On completion it creates a real [session] account and routes to /home.
/// SMS is mocked — any 4-digit code passes — so the flow stays free of paid
/// verification, matching the rest of this front-end-only preview.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _total = 3;

  final _page = PageController();
  int _step = 0;

  final _phone = TextEditingController();
  String _otp = '';
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  Timer? _resendTimer;
  int _resendIn = 0;

  @override
  void initState() {
    super.initState();
    // Re-evaluate the bottom-bar button as the user types.
    for (final c in [_phone, _name, _email, _password]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _page.dispose();
    _phone.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_step) {
        0 => _phone.text.trim().isNotEmpty,
        1 => _otp.length == 4,
        2 => _name.text.trim().isNotEmpty &&
            _email.text.trim().isNotEmpty &&
            _password.text.isNotEmpty,
        _ => false,
      };

  void _next() {
    if (!_canContinue) return;
    if (_step < _total - 1) {
      setState(() => _step++);
      _page.animateToPage(_step,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic);
      if (_step == 1) _startResendCountdown();
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) {
      context.canPop() ? context.pop() : context.go('/onboarding');
      return;
    }
    setState(() => _step--);
    _page.animateToPage(_step,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic);
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendIn = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendIn <= 1) {
        t.cancel();
        setState(() => _resendIn = 0);
      } else {
        setState(() => _resendIn--);
      }
    });
  }

  /// Finish sign-up: build the account, sign in, and enter the app.
  void _submit() {
    FocusScope.of(context).unfocus();
    final account = Account(
      name: _name.text.trim(),
      role: 'Home buyer',
      email: _email.text.trim(),
      investor: false,
      phone: '+855 ${_phone.text.trim()}',
    );
    session.signIn(account);
    investStore.signInNormal();
    context.go('/home');
  }

  /// Social sign-up shortcut — skips OTP, signs in the demo persona.
  void _social() {
    session.signIn(kNormalAccount);
    investStore.signInNormal();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Back button row — matches the sign-in screen.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    GlassIconButton(
                      asset: 'assets/icons/base/careleft.svg',
                      onTap: _back,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _page,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _stepPhone(),
                    _stepOtp(),
                    _stepProfile(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrap(List<Widget> children) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: children,
      );

  // ── Step 1 · Phone ─────────────────────────────────────────────────────────

  Widget _stepPhone() => _wrap([
        Center(
          child: Image.asset(
            'assets/images/logo_full.png',
            height: 46,
          ),
        ),
        const SizedBox(height: 32),
        const StepHeader(
          center: true,
          title: 'Create Account',
          subtitle: 'Enter your phone number to get started with PROPERTDIA.',
        ),
        const SizedBox(height: 22),
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _PhoneField(
          controller: _phone,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Continue',
          trailingIcon: null,
          enabled: _phone.text.trim().isNotEmpty,
          onPressed: _next,
        ),
        const SizedBox(height: 30),
        const _OrDivider(),
        const SizedBox(height: 22),
        googleButton(onTap: _social),
        const SizedBox(height: 12),
        facebookButton(onTap: _social),
        const SizedBox(height: 28),
        const Center(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              children: [
                TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: const Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13.5),
                children: [
                  TextSpan(
                    text: 'Already have an account?  ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextSpan(
                    text: 'Log in',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);

  // ── Step 2 · OTP ───────────────────────────────────────────────────────────

  Widget _stepOtp() => _wrap([
        StepHeader(
          title: 'Verify your number',
          subtitle:
              'Enter the 4-digit code sent to +855 ${_phone.text.trim()}.',
        ),
        const SizedBox(height: 24),
        _OtpInput(
          length: 4,
          onChanged: (v) => setState(() => _otp = v),
        ),
        const SizedBox(height: 22),
        Center(
          child: _resendIn > 0
              ? Text(
                  'Resend code in 0:${_resendIn.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : GestureDetector(
                  onTap: _startResendCountdown,
                  child: const Text(
                    'Resend code',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue',
          trailingIcon: null,
          enabled: _otp.length == 4,
          onPressed: _next,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/base/smartphone.svg',
                width: 16,
                height: 16,
                colorFilter:
                    const ColorFilter.mode(AppColors.navyIcon, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Demo build — no real SMS is sent. Enter any 4 digits to continue.',
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
      ]);

  // ── Step 3 · Profile ───────────────────────────────────────────────────────

  Widget _stepProfile() => _wrap([
        const StepHeader(
          title: 'Set up your profile',
          subtitle: 'Add your details and a password to finish.',
        ),
        const SizedBox(height: 22),
        _AuthField(
          label: 'Full name',
          icon: 'assets/icons/base/profile.svg',
          controller: _name,
          hint: 'Dara Sok',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        _AuthField(
          label: 'Email',
          icon: 'assets/icons/base/email.svg',
          controller: _email,
          hint: 'you@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _AuthField(
          label: 'Password',
          icon: 'assets/icons/base/locked.svg',
          controller: _password,
          hint: '••••••••',
          password: true,
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Create account',
          trailingIcon: null,
          enabled: _name.text.trim().isNotEmpty &&
              _email.text.trim().isNotEmpty &&
              _password.text.isNotEmpty,
          onPressed: _next,
        ),
      ]);
}

// ── Phone field ──────────────────────────────────────────────────────────────

class _PhoneField extends StatefulWidget {
  const _PhoneField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  final _focus = FocusNode();
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _active = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      height: 56,
      decoration: BoxDecoration(
        color: _active ? Colors.white : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _active ? AppColors.gold : AppColors.border,
          width: _active ? 1.5 : 1,
        ),
        boxShadow: _active
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Country picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image.network(
                    'https://flagcdn.com/w20/kh.png',
                    width: 22,
                    height: 15,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Text('🇰🇭', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '+855',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/base/caretdown.svg',
                  width: 13,
                  height: 13,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: _active
                ? AppColors.gold.withValues(alpha: 0.4)
                : AppColors.border,
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.gold,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                filled: false,
                hintText: '012 345 678',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: SvgPicture.asset(
              'assets/icons/base/smartphone.svg',
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                _active ? AppColors.gold : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OTP input ────────────────────────────────────────────────────────────────

/// Row of [length] single-digit boxes that auto-advance as the user types
/// and step back on delete. Reports the combined code via [onChanged].
class _OtpInput extends StatefulWidget {
  const _OtpInput({required this.length, required this.onChanged});

  final int length;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<_OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    for (final n in _nodes) {
      n.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String value) {
    if (value.isNotEmpty && i < widget.length - 1) {
      _nodes[i + 1].requestFocus();
    } else if (value.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < widget.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < widget.length - 1 ? 12 : 0),
              child: _box(i),
            ),
          ),
      ],
    );
  }

  Widget _box(int i) {
    final active = _nodes[i].hasFocus || _controllers[i].text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 62,
      decoration: BoxDecoration(
        color: active ? Colors.white : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.gold : AppColors.border,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[i],
          focusNode: _nodes[i],
          onChanged: (v) => _onChanged(i, v),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          cursorColor: AppColors.gold,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            counterText: '',
            isCollapsed: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ── Labeled text field (name / email / password) ─────────────────────────────

class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.password = false,
  });

  final String label;
  final String icon;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool password;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  final _focus = FocusNode();
  bool _active = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _active = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _active ? AppColors.gold : AppColors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _active ? Colors.white : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _active ? AppColors.gold : AppColors.border,
              width: _active ? 1.5 : 1,
            ),
            boxShadow: _active
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                widget.icon,
                width: 19,
                height: 19,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.password && _obscure,
                  keyboardType: widget.keyboardType,
                  cursorColor: AppColors.gold,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              if (widget.password)
                GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: SvgPicture.asset(
                    _obscure
                        ? 'assets/icons/base/eye_closed.svg'
                        : 'assets/icons/base/eye.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                        AppColors.textSecondary, BlendMode.srcIn),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Or divider ───────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.divider)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.divider)),
      ],
    );
  }
}
