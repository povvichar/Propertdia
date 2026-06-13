import 'package:go_router/go_router.dart';

import '../features/auth/register_screen.dart';
import '../features/estimate/data/valuation.dart';
import '../features/estimate/estimate_screen.dart';
import '../features/estimate/valuation_detail_screen.dart';
import '../features/estimate/valuation_wizard_screen.dart';
import '../features/home/home_screen.dart';
import '../features/map_price/map_price_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/property/property_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
        path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
      path: '/property',
      builder: (context, state) => const PropertyDetailScreen(),
    ),
    GoRoute(
      path: '/map-price',
      builder: (context, state) => const MapPriceScreen(),
    ),
    GoRoute(
      path: '/estimate',
      builder: (context, state) => const EstimateScreen(),
    ),
    GoRoute(
      path: '/estimate/new',
      builder: (context, state) => ValuationWizardScreen(
        type: state.extra as ValuationType? ?? ValuationType.building,
      ),
    ),
    GoRoute(
      path: '/estimate/detail',
      builder: (context, state) =>
          ValuationDetailScreen(valuation: state.extra as Valuation),
    ),
  ],
);
