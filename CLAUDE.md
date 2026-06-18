# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

PROPERTDIA is a Flutter **front-end-only client preview** of a Cambodian real-estate
platform. All data is mocked in-memory — there is no backend, no network calls, no
persistence across restarts.

## Commands

```bash
flutter pub get                       # install deps (run after pulling/editing pubspec)
flutter run                           # device / simulator
flutter run -d chrome                 # quick web preview
flutter analyze                       # lint (CI gate — keep clean)
flutter test                          # all tests
flutter test test/widget_test.dart    # single file

# Hot reload while `flutter run` is attached (this repo writes 'r' to a control pipe):
printf 'r' > /tmp/flutter_ctl

flutter build ios --release
```

## State management — read this first

The app uses **two parallel state mechanisms**; pick the right one:

1. **Riverpod** — only for app-shell concerns. Just two providers exist
   (`lib/shared/providers/app_providers.dart`): `homeTabProvider`
   (`StateProvider<int>`, active bottom-nav tab) and `languageProvider`. Screens that
   touch these are `ConsumerWidget`/`ConsumerStatefulWidget`.

2. **Global singleton `ChangeNotifier` stores** — for all feature/domain data. Each
   feature owns one, declared as a top-level `final` instance in its `data/` file and
   imported directly (no DI, no Riverpod wrapper):
   - `favoritesStore` — `favorites/data/favorites.dart` (saved properties + projects;
     **single source of truth for favorites** — do not duplicate favorite state onto other stores)
   - `valuationStore` — `estimate/data/valuation.dart`
   - `investStore` — `invest/data/invest.dart`
   - `savedForceSale` (`SavedStore`) — `force_sale/data/force_sale.dart`
   - `Session` — `auth/data/account.dart`

   Screens read these by wrapping the relevant subtree in
   `AnimatedBuilder(animation: theStore, builder: ...)` and mutate via store methods
   that call `notifyListeners()`. When adding domain state, follow this store pattern,
   not Riverpod.

## Navigation

GoRouter, all routes flat/top-level in `lib/routes/app_router.dart` (no nested/shell
routing). Objects are passed between screens via `state.extra` (cast it, e.g.
`state.extra as Valuation`); wizard entry routes also read `state.extra` for a type
enum with a default fallback. Add a new screen by registering a `GoRoute` here.

The `/home` route is the app shell: an `IndexedStack` over four tabs
(`_HomeBody`, `FavoritesView`, `MediaView`, `ProfileView`) driven by `homeTabProvider`,
with the `_GlassNav` liquid-glass pill as `bottomNavigationBar`.
**Do not modify `_GlassNav`** unless explicitly asked.

## Feature modules

Feature-first under `lib/features/<module>/`, each typically with `data/` (models +
store), a list screen, `*_detail_screen.dart`, optional `*_wizard_screen.dart`, and
`widgets/`. Modules: `onboarding`, `auth`, `home`, `map_price`, `estimate`, `title`,
`force_sale`, `invest`, `partnership`, `media`, `favorites`, `profile`, `property`,
`notifications`.

Shared building blocks live in `lib/shared/` (`models/`, `data/cambodia.dart`,
`utils/format.dart`, and many reusable `widgets/`). `lib/core/theme/` holds the design
tokens.

### Reusable patterns to prefer over reinventing

- **Collapsing hero header** — `shared/widgets/module_hero_sliver.dart`
  (`ModuleHeroSliver` + `ModuleHeroSheet`): navy gradient `SliverAppBar` that collapses
  to a pinned bar, used by Estimate / Title / Partnership. Note: it sets `stretch: true`
  and intentionally has **no `shape`** (a `shape` lets the navy bg bleed into the corner
  notches). Reuse it for any new module landing screen.
- **Multi-step wizards** — `valuation_wizard_screen.dart`, `title_request_wizard_screen.dart`
  with `shared/widgets/wizard_header.dart` + `wizard_bottom_bar.dart`. Gotcha: the
  `PageView` eagerly builds all steps, so **null-guard draft fields** that aren't filled
  on earlier pages.
- Other shared widgets: `glass_panel`, `glass_icon_button`, `primary_button`,
  `app_search_bar`, `form_fields`, `bank_select`, `map_pick_field`, `photo_gallery`,
  `tier_badge`, `location_picker_screen`.

## Theme & styling conventions

- Always use `AppColors` (`core/theme/app_colors.dart`) and `AppTextStyles`
  (`core/theme/app_text_styles.dart`). Never hardcode a color or inline a raw
  `TextStyle` when a semantic token exists.
- Brand: gold `#F2A71B` / secondary `#E4A623`, navy primary `#0B113E` /`#1E2A47`,
  background `#F1F3F8`; success `#0F973D`, warning `#F3A218`, error `#EF4444`,
  info `#0088FF`.
- Font is **Manrope** via `google_fonts`, applied globally in `AppTheme.light`
  (`GoogleFonts.manropeTextTheme`); use `GoogleFonts.manrope(...)` for overrides.
  (The README's mention of "Inter" is stale.)
- Lints enforce `prefer_const_constructors` and
  `prefer_const_literals_to_create_immutables` (see `analysis_options.yaml`) — keep
  widget trees `const` where possible.
- Press feedback uses `AnimatedScale` + `GestureDetector`, scaling to ~0.93–0.97× on
  press and restoring on release/cancel.
- Assets: SVGs via `flutter_svg` from `assets/icons/base/` (shared 88-icon set) and
  `assets/icons/home/` (service grid); images in `assets/images/`. Register new asset
  dirs in `pubspec.yaml`.

## Maps

`map_price` uses `flutter_map` + `latlong2` (OpenStreetMap-style tiles), not Google
Maps. `LatLng` from `latlong2` flows through routes (`/pick-location`).

## Notes

- Property photos are Unsplash placeholders.
- The Home design labels the 2nd service tile "Map Price" by copy-paste typo; it is
  intentionally implemented as **"Force Sale"** (matches the `Force Sale.svg` asset).
- Investor membership: application form stays *pending*; **long-press the pending card**
  to demo-approve (intentional — there is no auto-approve).
</content>
</invoke>
