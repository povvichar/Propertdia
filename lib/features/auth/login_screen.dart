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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn(Account account) {
    session.signIn(account);
    if (account.investor) {
      investStore.signInInvestor();
    } else {
      investStore.signInNormal();
    }
    context.go('/home');
  }

  void _manualLogin() {
    // Unified identifier: match the typed phone OR email against a demo
    // account, otherwise fall back to the normal persona. Password-based,
    // no SMS — keeps the auth flow free of paid verification.
    final id = _email.text.trim().toLowerCase();
    final match = mockAccounts.firstWhere(
      (a) => a.email.toLowerCase() == id || a.phone == _email.text.trim(),
      orElse: () => kNormalAccount,
    );
    _signIn(match);
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
              // Back button row — matches the wizard header treatment.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    GlassIconButton(
                      asset: 'assets/icons/base/careleft.svg',
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/onboarding'),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo_full.png',
                        height: 46,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const StepHeader(
                      center: true,
                      title: 'Sign In',
                      subtitle: 'Welcome back! Enter your credentials '
                          'to continue.',
                    ),
                    const SizedBox(height: 24),

                    _Field(
                      label: 'Phone or email',
                      icon: 'assets/icons/base/profile.svg',
                      controller: _email,
                      hint: '012 345 678  or  you@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _Field(
                      label: 'Password',
                      icon: 'assets/icons/base/locked.svg',
                      controller: _password,
                      hint: '••••••••',
                      obscure: _obscure,
                      trailing: GestureDetector(
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
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      label: 'Log in',
                      trailingIcon: null,
                      onPressed: _manualLogin,
                    ),

                    const SizedBox(height: 30),

                    const _OrDivider(),

                    const SizedBox(height: 22),

                    googleButton(onTap: () => _signIn(kNormalAccount)),
                    const SizedBox(height: 12),
                    facebookButton(onTap: () => _signIn(kNormalAccount)),

                    const SizedBox(height: 28),

                    _DemoPicker(onPick: _signIn),

                    const SizedBox(height: 28),

                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: 13.5),
                            children: [
                              TextSpan(
                                text: 'New here?  ',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                              TextSpan(
                                text: 'Create account',
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

class _DemoPicker extends StatelessWidget {
  const _DemoPicker({required this.onPick});

  final ValueChanged<Account> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Demo:',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 8),
        _DemoPill(
          label: 'User',
          color: AppColors.navy,
          onTap: () => onPick(kNormalAccount),
        ),
        const SizedBox(width: 8),
        _DemoPill(
          label: 'Investor',
          color: AppColors.goldDark,
          onTap: () => onPick(kInvestorAccount),
        ),
      ],
    );
  }
}

class _DemoPill extends StatelessWidget {
  const _DemoPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
  });

  final String label;
  final String icon;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
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
                  obscureText: widget.obscure,
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
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ],
    );
  }
}
