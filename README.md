# PROPERTDIA — Front-End UI (Client Preview)

Flutter implementation of the PROPERTDIA mobile app UI, built from the Figma
designs (Onboarding + Home V3). Front-end only: all data is mocked, no backend
calls.

**Brand:** Gold `#F2A71B` · Navy `#1E2A47` · Background `#F1F3F8` · Inter typeface

## Screens

| Route | Screen |
|---|---|
| `/` | Splash — gold diamond-pattern background, brand mark, auto-advances |
| `/language` | Choose Language — Khmer / English selection (Riverpod state) |
| `/onboarding` | 3 feature slides — Map Prices, Property Estimate, Title Services |
| `/home` | Home — location header, search, hero banner, service grid, listings, bottom nav |

## Stack (per the approved tech-stack document)

Flutter · Dart · Riverpod (state) · GoRouter (navigation) · feature-first
`lib/` structure (`core/`, `shared/`, `features/`, `routes/`).

## Run

```bash
flutter pub get
flutter run            # device/simulator
flutter run -d chrome  # quick web preview
```

## Assets

Brand assets live in `assets/` (copied from the design handoff):
`images/logo.png` (full lockup), `images/logo_mark.png` (house mark, cropped),
`images/onboarding_*.png` (Flash Screens), `icons/home/` (service-grid SVGs),
`icons/base/` (88-icon base set, not all wired up yet).

## Notes for design review

- The Home V3 frame labels the second service tile "Map Price" (copy-paste
  typo); per the asset name `Force Sale.svg` it is implemented as **"Force Sale"**.
- Property photos are Unsplash placeholders; replace with listing API images
  when the backend is connected.
