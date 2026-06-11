import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();
  bool _hasInput = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: SvgPicture.asset(
                      'assets/icons/base/caretright.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your phone number to get started\nwith PROPERTDIA.',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Phone label
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phone field
                    _PhoneField(
                      controller: _phoneController,
                      onChanged: (v) => setState(() => _hasInput = v.isNotEmpty),
                    ),

                    const SizedBox(height: 20),

                    // Continue
                    _ContinueButton(enabled: _hasInput, onPressed: () {}),

                    const SizedBox(height: 32),

                    // Divider
                    const _OrDivider(),

                    const SizedBox(height: 24),

                    // Google
                    _SocialButton(
                      onTap: () {},
                      logo: SvgPicture.string(_kGoogleSvg, width: 20, height: 20),
                      label: 'Continue with Google',
                      background: Colors.white,
                      foreground: AppColors.textPrimary,
                      borderColor: const Color(0xFFE3E6EE),
                    ),
                    const SizedBox(height: 12),

                    // Facebook
                    _SocialButton(
                      onTap: () {},
                      logo: SvgPicture.string(_kFacebookSvg, width: 20, height: 20),
                      label: 'Continue with Facebook',
                      background: const Color(0xFF1877F2),
                      foreground: Colors.white,
                      borderColor: Colors.transparent,
                    ),

                    const SizedBox(height: 36),

                    // Terms
                    Center(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          children: [
                            const TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Log in
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 13.5),
                            children: [
                              const TextSpan(
                                text: 'Already have an account?  ',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              TextSpan(
                                text: 'Log in',
                                style: const TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}

// ── Phone field ──────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E6EE), width: 1),
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
          Container(width: 1, height: 28, color: const Color(0xFFE3E6EE)),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '012 345 678',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: SvgPicture.asset(
              'assets/icons/base/smartphone.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Continue button ──────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 54,
      decoration: BoxDecoration(
        color: enabled ? AppColors.gold : AppColors.gold.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              SvgPicture.asset(
                'assets/icons/base/arrowright.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
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
        Expanded(child: Container(height: 1, color: const Color(0xFFE3E6EE))),
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
        Expanded(child: Container(height: 1, color: const Color(0xFFE3E6EE))),
      ],
    );
  }
}

// ── Social button ────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.logo,
    required this.label,
    required this.background,
    required this.foreground,
    required this.borderColor,
  });

  final VoidCallback onTap;
  final Widget logo;
  final String label;
  final Color background;
  final Color foreground;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logo,
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Inline brand SVGs ────────────────────────────────────────────────────────

const _kGoogleSvg = '''
<svg viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
  <path fill="#4285F4" d="M17.64 9.205c0-.639-.057-1.252-.164-1.841H9v3.481h4.844a4.14 4.14 0 01-1.796 2.716v2.259h2.908c1.702-1.567 2.684-3.875 2.684-6.615z"/>
  <path fill="#34A853" d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 009 18z"/>
  <path fill="#FBBC05" d="M3.964 10.71A5.41 5.41 0 013.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 000 9c0 1.452.348 2.827.957 4.042l3.007-2.332z"/>
  <path fill="#EA4335" d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 00.957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58z"/>
</svg>
''';

const _kFacebookSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path fill="white" d="M13.397 20.997v-8.196h2.765l.411-3.209h-3.176V7.548c0-.926.258-1.56 1.587-1.56h1.684V3.127A22.336 22.336 0 0014.201 3c-2.444 0-4.122 1.492-4.122 4.231v2.355H7.332v3.209h2.753v8.202h3.312z"/>
</svg>
''';
