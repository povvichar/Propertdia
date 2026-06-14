import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
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

// ── Language data ─────────────────────────────────────────────────────────────

class _LangOption {
  const _LangOption(this.lang, this.flag, this.label);
  final AppLanguage lang;
  final String flag;
  final String label;
}

const _langOptions = [
  _LangOption(AppLanguage.english, 'assets/icons/base/english.svg', 'English'),
  _LangOption(AppLanguage.khmer, 'assets/icons/base/khmer.svg', 'ភាសាខ្មែរ'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _langOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _pages.length - 1) {
      context.go('/register');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(languageProvider);

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

          // Tap-outside barrier — sits below UI, closes dropdown on background tap
          if (_langOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _langOpen = false),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LangPicker(
                        selected: selected,
                        isOpen: _langOpen,
                        onToggle: () => setState(() => _langOpen = !_langOpen),
                        onSelect: (lang) {
                          ref.read(languageProvider.notifier).state = lang;
                          setState(() => _langOpen = false);
                        },
                      ),
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
                  PrimaryButton(
                    label:
                        _page == _pages.length - 1 ? 'Get Started' : 'Continue',
                    onPressed: _next,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white, fontSize: 13.5),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
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

// ── Liquid-glass language picker ──────────────────────────────────────────────

class _LangPicker extends StatefulWidget {
  const _LangPicker({
    required this.selected,
    required this.isOpen,
    required this.onToggle,
    required this.onSelect,
  });

  final AppLanguage selected;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<AppLanguage> onSelect;

  @override
  State<_LangPicker> createState() => _LangPickerState();
}

class _LangPickerState extends State<_LangPicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _chevron;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _chevron = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_LangPicker old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _langOptions.firstWhere((o) => o.lang == widget.selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Pill trigger ─────────────────────────────────────────────────────
        GestureDetector(
          onTap: widget.onToggle,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                width: 120,
                height: 40,
                padding: const EdgeInsets.only(left: 10, right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      current.flag,
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        current.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _chevron,
                      child: SvgPicture.asset(
                        'assets/icons/base/caretdown.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Animated dropdown — stays in tree during exit animation ──────────
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            if (_ctrl.value == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  alignment: Alignment.topLeft,
                  child: child,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < _langOptions.length; i++) ...[
                      if (i > 0)
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.09),
                        ),
                      _DropdownItem(
                        option: _langOptions[i],
                        isSelected: _langOptions[i].lang == widget.selected,
                        onTap: () => widget.onSelect(_langOptions[i].lang),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dropdown row item ─────────────────────────────────────────────────────────

class _DropdownItem extends StatefulWidget {
  const _DropdownItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _LangOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: (_pressed || widget.isSelected)
              ? Colors.white.withValues(alpha: 0.11)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              widget.option.flag,
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.option.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (widget.isSelected)
              const Icon(Icons.check_rounded, size: 16, color: AppColors.gold),
          ],
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
