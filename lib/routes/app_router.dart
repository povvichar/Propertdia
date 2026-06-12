import 'package:go_router/go_router.dart';

import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
  ],
);
