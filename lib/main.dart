import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_router.dart';
import 'shared/providers/app_providers.dart';
import 'shared/utils/l10n_text.dart' as l10n_text;

/// Weights the UI actually uses for Khmer text (see `AppTextStyles`). The Khmer
/// fallback font (Kantumruy Pro, via google_fonts) only registers a weight when
/// it is requested, so we must load each one — otherwise bold Khmer renders as
/// synthetic bold off the regular face instead of the real weight. Kantumruy Pro
/// tops out at w700, so the w800 `price` style falls back to w700 for Khmer.
const _khmerWeights = [
  FontWeight.w400,
  FontWeight.w500,
  FontWeight.w600,
  FontWeight.w700,
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register every Khmer weight up front so the fallback renders true bolds.
  for (final w in _khmerWeights) {
    GoogleFonts.kantumruyPro(fontWeight: w);
  }
  // Wait for the faces to finish loading so the first frame isn't a synthetic
  // bold flash; guarded so an offline first run still boots (uses cache/system).
  try {
    await GoogleFonts.pendingFonts();
  } catch (_) {
    // Ignore — fonts will load/cache lazily and the tree rebuilds when ready.
  }
  runApp(const ProviderScope(child: PropertdiaApp()));
}

class PropertdiaApp extends ConsumerWidget {
  const PropertdiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    // Keep the context-free mirror used by mock-data getters in sync.
    l10n_text.currentLanguage = lang;

    return MaterialApp.router(
      title: 'PROPERTDIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: lang == AppLanguage.khmer
          ? const Locale('km')
          : const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
