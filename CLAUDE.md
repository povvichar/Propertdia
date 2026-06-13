# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a connected device / simulator
flutter run

# Hot reload (app must already be running via flutter run)
printf 'r' > /tmp/flutter_ctl

# Analyze & lint
flutter analyze

# Run tests
flutter test
flutter test test/widget_test.dart   # single file

# Build iOS release
flutter build ios --release
```

## Architecture

Feature-first layout under `lib/`:

```
lib/
  main.dart                  # ProviderScope + MaterialApp.router
  routes/app_router.dart     # GoRouter — splash → onboarding → home → register
  core/theme/
    app_colors.dart          # All brand tokens (colors, gradients, shadow presets)
    app_text_styles.dart     # Inter-based semantic scale (display/title/body/label/price)
    app_theme.dart           # MaterialTheme wired to GoogleFonts.interTextTheme
  features/
    onboarding/              # splash_screen, onboarding_screen, language_screen
    auth/                    # register_screen
    home/
      home_screen.dart       # Scaffold + CustomScrollView + _GlassNav (do not modify nav)
      widgets/
        home_header.dart     # Location row + search bar
        service_grid.dart    # 3×2 quick-action grid
        property_card.dart   # Animated card with glass tag badge
  shared/
    models/property.dart     # Property data class + mockBestPrice list
    providers/app_providers.dart  # homeTabProvider (Riverpod StateProvider<int>)
    widgets/                 # brand_logo, primary_button
```

## Key conventions

- **State**: Riverpod (`flutter_riverpod`). Only `homeTabProvider` exists today — a `StateProvider<int>` for the bottom nav tab index.
- **Navigation**: GoRouter. All routes are top-level in `app_router.dart`; no nested routing yet.
- **Theme**: Always use `AppColors` and `AppTextStyles` constants. Never hardcode colors or raw `TextStyle` inline if a semantic token exists.
- **Fonts**: Inter via `google_fonts`. Applied globally through `AppTheme.light`; use `GoogleFonts.inter(...)` for overrides.
- **Assets**: SVG icons via `flutter_svg` (`SvgPicture.asset`). Icons live in `assets/icons/base/` (shared) and `assets/icons/home/` (home grid). Images in `assets/images/`.
- **Bottom nav**: `_GlassNav` in `home_screen.dart` — liquid-glass pill, must not be modified unless explicitly requested.
- **Press animations**: Use `AnimatedScale` + `GestureDetector` pattern (see `_ServiceTile`, `_PropertyCardState`). Scale down on press (0.93–0.97×), restore on release/cancel.
- **Colors**: secondary `#E4A623`, primary `#0B113E`, success `#0F973D`, warning `#F3A218`, error `#EF4444`, info `#0088FF`.
