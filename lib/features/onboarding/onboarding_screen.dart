import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/primary_button.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.asset,
  });

  final String title;
  final String subtitle;
  final String asset;
}

const _pages = [
  _OnboardingPage(
    title: 'Real Prices on the Map',
    subtitle: 'Browse live market prices and trends by area.',
    asset: 'assets/images/onboarding_map.png',
  ),
  _OnboardingPage(
    title: 'Quick Property Estimate',
    subtitle:
        'Get an instant price indication based on type, size, and location.',
    asset: 'assets/images/onboarding_estimate.png',
  ),
  _OnboardingPage(
    title: 'Title Services in Cambodia',
    subtitle:
        'Verify property ownership and legal documents with trusted local experts.',
    asset: 'assets/images/onboarding_title.png',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _pages.length - 1) {
      context.go('/home');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => _OnboardingSlide(page: _pages[i]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LangPicker(ref: ref),
                      TextButton(
                        onPressed: () => context.go('/home'),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _PageDots(count: _pages.length, active: _page),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Continue', onPressed: _next),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white, fontSize: 13.5),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/home'),
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Liquid-glass language picker ─────────────────────────────────────────────

class _LangOption {
  const _LangOption(this.lang, this.flag, this.label);
  final AppLanguage lang;
  final String flag;
  final String label;
}

const _langOptions = [
  _LangOption(AppLanguage.english, 'assets/icons/base/english.svg', 'English'),
  _LangOption(AppLanguage.khmer, 'assets/icons/base/khmer.svg', 'Khmer'),
];

class _LangPicker extends StatefulWidget {
  const _LangPicker({required this.ref});
  final WidgetRef ref;

  @override
  State<_LangPicker> createState() => _LangPickerState();
}

class _LangPickerState extends State<_LangPicker>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _anim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: -6, end: 0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _anim.forward() : _anim.reverse();
  }

  void _select(AppLanguage lang) {
    widget.ref.read(languageProvider.notifier).state = lang;
    setState(() => _open = false);
    _anim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.ref.watch(languageProvider);
    final current = _langOptions.firstWhere((o) => o.lang == selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: _GlassPill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(current.flag, width: 16, height: 16),
                const SizedBox(width: 6),
                Text(
                  current.label,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _anim,
          builder: (context, child) => Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: child,
            ),
          ),
          child: _open
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _GlassPill(
                    radius: 12,
                    child: IntrinsicWidth(
                      stepWidth: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _langOptions
                            .map(
                              (o) => GestureDetector(
                                onTap: () => _select(o.lang),
                                child: SizedBox(
                                  height: 36,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(o.flag, width: 16, height: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          o.label,
                                          style: AppTextStyles.labelLarge.copyWith(
                                            fontWeight: o.lang == selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: o.lang == selected
                                                ? Colors.white
                                                : Colors.white70,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: o.lang == selected
                                            ? AppColors.gold
                                            : Colors.transparent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child, this.radius = 100});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Slide ─────────────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(page.asset, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Color(0x001E2A47), Color(0xCC1E2A47)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 190),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textOnDarkMuted,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Page dots ─────────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 22,
            height: 5,
            decoration: BoxDecoration(
              color: i == active ? AppColors.gold : Colors.white38,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
