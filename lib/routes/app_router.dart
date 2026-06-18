import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../features/about/about_screen.dart';
import '../features/about/data/about.dart';
import '../features/about/team_member_detail_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/estimate/data/valuation.dart';
import '../features/estimate/estimate_screen.dart';
import '../features/estimate/instant_estimate_screen.dart';
import '../features/estimate/valuation_detail_screen.dart';
import '../features/estimate/valuation_wizard_screen.dart';
import '../features/estimate/valuations_screen.dart';
import '../features/force_sale/data/force_sale.dart';
import '../features/force_sale/force_sale_detail_screen.dart';
import '../features/force_sale/force_sale_screen.dart';
import '../features/home/home_screen.dart';
import '../features/invest/data/invest.dart';
import '../features/invest/deposit_screen.dart';
import '../features/invest/invest_detail_screen.dart';
import '../features/invest/invest_screen.dart';
import '../features/invest/investor_application_screen.dart';
import '../features/map_price/map_price_screen.dart';
import '../features/media/data/media.dart';
import '../features/media/media_detail_screen.dart';
import '../features/partnership/partnership_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/property/property_detail_screen.dart';
import '../features/title/data/title_service.dart';
import '../shared/widgets/location_picker_screen.dart';
import '../features/title/title_detail_screen.dart';
import '../features/title/title_request_wizard_screen.dart';
import '../features/title/title_screen.dart';
import '../features/title/eligibility_screen.dart';
import '../features/notifications/notification_screen.dart';
import '../features/profile/profile_settings_screens.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/about/team',
      builder: (context, state) =>
          TeamMemberDetailScreen(
              member: state.extra as TeamMember? ?? aboutTeam.first),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
      path: '/estimate/instant',
      builder: (context, state) => const InstantEstimateScreen(),
    ),
    GoRoute(
      path: '/estimate/valuations',
      builder: (context, state) => const ValuationsScreen(),
    ),
    GoRoute(
      path: '/estimate/new',
      builder: (context, state) {
        final pf = state.extra as EstimatePrefill?;
        return ValuationWizardScreen(
          type: pf?.type ?? ValuationType.building,
          prefill: pf,
        );
      },
    ),
    GoRoute(
      path: '/estimate/detail',
      builder: (context, state) =>
          ValuationDetailScreen(valuation: state.extra as Valuation),
    ),
    GoRoute(
      path: '/title',
      builder: (context, state) => const TitleScreen(),
    ),
    GoRoute(
      path: '/title/eligibility',
      builder: (context, state) => const EligibilityScreen(),
    ),
    GoRoute(
      path: '/title/new',
      builder: (context, state) => TitleRequestWizardScreen(
        type: state.extra as TitleServiceType? ?? TitleServiceType.verification,
      ),
    ),
    GoRoute(
      path: '/title/detail',
      builder: (context, state) =>
          TitleDetailScreen(app: state.extra as TitleApplication),
    ),
    GoRoute(
      path: '/pick-location',
      builder: (context, state) =>
          LocationPickerScreen(initial: state.extra as LatLng?),
    ),
    GoRoute(
      path: '/force-sale',
      builder: (context, state) => const ForceSaleScreen(),
    ),
    GoRoute(
      path: '/force-sale/detail',
      builder: (context, state) =>
          ForceSaleDetailScreen(property: state.extra as ForceSaleProperty),
    ),
    GoRoute(
      path: '/invest',
      builder: (context, state) => const InvestScreen(),
    ),
    GoRoute(
      path: '/invest/deposit',
      builder: (context, state) => const DepositScreen(),
    ),
    GoRoute(
      path: '/invest/detail',
      builder: (context, state) =>
          InvestDetailScreen(project: state.extra as InvestProject),
    ),
    GoRoute(
      path: '/invest/portfolio',
      builder: (context, state) => const PortfolioScreen(),
    ),
    GoRoute(
      path: '/invest/apply',
      builder: (context, state) => const InvestorApplicationScreen(),
    ),
    GoRoute(
      path: '/invest/transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),
    GoRoute(
      path: '/invest/opportunities',
      builder: (context, state) => const OpportunitiesScreen(),
    ),
    GoRoute(
      path: '/partnership',
      builder: (context, state) => const PartnershipScreen(),
    ),
    GoRoute(
      path: '/media/post',
      builder: (context, state) => MediaDetailScreen(post: state.extra as Post),
    ),
    GoRoute(
      path: '/profile/personal',
      builder: (context, state) => const PersonalInfoScreen(),
    ),
    GoRoute(
      path: '/profile/kyc',
      builder: (context, state) => const KycScreen(),
    ),
    GoRoute(
      path: '/profile/security',
      builder: (context, state) => const SecurityScreen(),
    ),
    GoRoute(
      path: '/profile/transactions',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/profile/applications',
      builder: (context, state) => const ApplicationHistoryScreen(),
    ),
    GoRoute(
      path: '/profile/drafts',
      builder: (context, state) => const SavedDraftsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/profile/notifications',
      builder: (context, state) => const NotificationPrefsScreen(),
    ),
    GoRoute(
      path: '/profile/support',
      builder: (context, state) => const TelegramSupportScreen(),
    ),
  ],
);
